﻿using System;
using System.Linq;
using System.Text;
using DotNetty.Buffers;

namespace SupercellUilityApi.Helpers
{
    /// <summary>
    ///     This implements a few extensions for games from Supercell
    /// </summary>
    public static class Writer
    {
        /// <summary>
        ///     Encodes a string based on the length
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="value"></param>
        public static void WriteScString(this IByteBuffer buffer, string value)
        {
            if (value == null)
            {
                buffer.WriteInt(-1);
            }
            else if (value.Length == 0)
            {
                buffer.WriteInt(0);
            }
            else
            {
                var bytes = Encoding.UTF8.GetBytes(value);

                buffer.WriteInt(bytes.Length);
                buffer.WriteString(value, Encoding.UTF8);
            }
        }

        /// <summary>
        ///     Encodes a VInt
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="value"></param>
        public static void WriteVInt(this IByteBuffer buffer, int value)
        {
            var temp = (value >> 25) & 0x40;
            var flipped = value ^ (value >> 31);

            temp |= value & 0x3F;
            value >>= 6;

            if ((flipped >>= 6) == 0)
            {
                buffer.WriteByte(temp);
                return;
            }

            buffer.WriteByte(temp | 0x80);

            do
            {
                buffer.WriteByte((value & 0x7F) | ((flipped >>= 7) != 0 ? 0x80 : 0));
                value >>= 7;
            } while (flipped != 0);
        }

        /// <summary>
        ///     This method should be only used for testing.
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="value"></param>
        public static void WriteHex(this IByteBuffer buffer, string value)
        {
            var tmp = value.Replace("-", string.Empty).Replace("-", string.Empty);
            buffer.WriteBytes(Enumerable.Range(0, tmp.Length).Where(x => x % 2 == 0)
                .Select(x => Convert.ToByte(tmp.Substring(x, 2), 16)).ToArray());
        }
    }
}