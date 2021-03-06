// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "components/viz/test/test_shared_bitmap_manager.h"

#include <stdint.h>

#include "base/memory/shared_memory.h"
#include "components/viz/common/resources/resource_format_utils.h"
#include "mojo/public/cpp/system/platform_handle.h"

namespace viz {

TestSharedBitmapManager::TestSharedBitmapManager() = default;

TestSharedBitmapManager::~TestSharedBitmapManager() {
  DCHECK_CALLED_ON_VALID_SEQUENCE(sequence_checker_);
}

std::unique_ptr<SharedBitmap> TestSharedBitmapManager::GetSharedBitmapFromId(
    const gfx::Size&,
    ResourceFormat,
    const SharedBitmapId& id) {
  DCHECK_CALLED_ON_VALID_SEQUENCE(sequence_checker_);

  if (bitmap_map_.find(id) == bitmap_map_.end())
    return nullptr;
  uint8_t* pixels = static_cast<uint8_t*>(bitmap_map_[id]->memory());
  return std::make_unique<SharedBitmap>(pixels);
}

base::UnguessableToken
TestSharedBitmapManager::GetSharedBitmapTracingGUIDFromId(
    const SharedBitmapId& id) {
  if (bitmap_map_.find(id) == bitmap_map_.end())
    return {};
  return bitmap_map_[id]->mapped_id();
}

bool TestSharedBitmapManager::ChildAllocatedSharedBitmap(
    mojo::ScopedSharedBufferHandle buffer,
    const SharedBitmapId& id) {
  DCHECK_CALLED_ON_VALID_SEQUENCE(sequence_checker_);

  // TestSharedBitmapManager is both the client and service side. So the
  // notification here should be about a bitmap that was previously allocated
  // with AllocateSharedBitmap().
  if (bitmap_map_.find(id) == bitmap_map_.end()) {
    base::SharedMemoryHandle memory_handle;
    size_t buffer_size;
    MojoResult result = mojo::UnwrapSharedMemoryHandle(
        std::move(buffer), &memory_handle, &buffer_size, nullptr);
    DCHECK_EQ(result, MOJO_RESULT_OK);
    auto memory = std::make_unique<base::SharedMemory>(memory_handle, false);
    bool mapped = memory->Map(buffer_size);
    DCHECK(mapped);
    memory->Close();

    bitmap_map_.emplace(id, memory.get());
    owned_map_.emplace(id, std::move(memory));
  }

  // The same bitmap id should not be notified more than once.
  DCHECK_EQ(notified_set_.count(id), 0u);
  notified_set_.insert(id);
  return true;
}

void TestSharedBitmapManager::ChildDeletedSharedBitmap(
    const SharedBitmapId& id) {
  DCHECK_CALLED_ON_VALID_SEQUENCE(sequence_checker_);

  notified_set_.erase(id);
  bitmap_map_.erase(id);
  owned_map_.erase(id);
}

}  // namespace viz
