﻿using System.Text;
using DotNetty.Buffers;

namespace SupercellUilityApi.Helpers
{
    /// <summary>
    ///     This implements a few extensions for games from Supercell
    /// </summary>
    public static class Reader
    {
        /// <summary>
        ///     Decodes a string based on the length
        /// </summary>
        /// <param name="byteBuffer"></param>
        /// <returns></returns>
        public static string ReadScString(this IByteBuffer byteBuffer)
        {
            var length = byteBuffer.ReadInt();

            if (length <= 0 || length > 900000)
                return string.Empty;

            return byteBuffer.ReadString(length, Encoding.UTF8);
        }

        /// <summary>
        ///     Decodes a VInt
        /// </summary>
        /// <param name="byteBuffer"></param>
        /// <returns></returns>
        public static int ReadVInt(this IByteBuffer byteBuffer)
        {
            int b, sign = ((b = byteBuffer.ReadByte()) >> 6) & 1, i = b & 0x3F, offset = 6;

            for (var j = 0; j < 4 && (b & 0x80) != 0; j++, offset += 7)
                i |= ((b = byteBuffer.ReadByte()) & 0x7F) << offset;

            return (b & 0x80) != 0 ? -1 : i | (sign == 1 && offset < 32 ? i | (int)(0xFFFFFFFF << offset) : i);
        }
    }
}
