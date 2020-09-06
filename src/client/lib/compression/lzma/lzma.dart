import 'dart:convert';

import 'src/lzma.dart' as lzma_impl;

const LzmaCodec lzma = const LzmaCodec();

class LzmaCodec extends Codec<List<int>, List<int>> {
  const LzmaCodec();

  @override
  Converter<List<int>, List<int>> get encoder => const LzmaEncoder();

  @override
  Converter<List<int>, List<int>> get decoder => const LzmaDecoder();
}

class LzmaEncoder extends Converter<List<int>, List<int>> {
  const LzmaEncoder();

  @override
  List<int> convert(List<int> input) {
    final inStream = new lzma_impl.InStream(input);
    final outStream = new lzma_impl.OutStream();
    lzma_impl.compress(inStream, outStream);
    return outStream.data;
  }
}

class LzmaDecoder extends Converter<List<int>, List<int>> {
  const LzmaDecoder();

  @override
  List<int> convert(List<int> encoded) {
    final inStream = new lzma_impl.InStream(encoded);
    final outStream = new lzma_impl.OutStream();
    lzma_impl.decompress(inStream, outStream);
    return outStream.data;
  }
}
