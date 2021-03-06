// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef SKIA_PUBLIC_INTERFACES_BITMAP_SKBITMAP_STRUCT_TRAITS_H_
#define SKIA_PUBLIC_INTERFACES_BITMAP_SKBITMAP_STRUCT_TRAITS_H_

#include "base/containers/span.h"
#include "mojo/public/cpp/base/big_buffer.h"
#include "mojo/public/cpp/base/big_buffer_mojom_traits.h"
#include "mojo/public/cpp/bindings/array_traits.h"
#include "skia/public/interfaces/bitmap.mojom.h"
#include "skia/public/interfaces/image_info_struct_traits.h"
#include "third_party/skia/include/core/SkBitmap.h"

namespace mojo {

// Struct traits to use SkBitmap for skia::mojom::Bitmap in Chrome C++ code.
template <>
struct StructTraits<skia::mojom::BitmapDataView, SkBitmap> {
  static bool IsNull(const SkBitmap& b);
  static void SetToNull(SkBitmap* b);
  static const SkImageInfo& image_info(const SkBitmap& b);
  static uint64_t row_bytes(const SkBitmap& b);
  static mojo_base::BigBufferView pixel_data(const SkBitmap& b);
  static bool Read(skia::mojom::BitmapDataView data, SkBitmap* b);
};

template <>
struct StructTraits<skia::mojom::InlineBitmapDataView, SkBitmap> {
  static bool IsNull(const SkBitmap& b);
  static void SetToNull(SkBitmap* b);
  static const SkImageInfo& image_info(const SkBitmap& b);
  static uint64_t row_bytes(const SkBitmap& b);
  static base::span<const uint8_t> pixel_data(const SkBitmap& b);
  static bool Read(skia::mojom::InlineBitmapDataView data, SkBitmap* b);
};

}  // namespace mojo

#endif  // SKIA_PUBLIC_INTERFACES_BITMAP_SKBITMAP_STRUCT_TRAITS_H_
