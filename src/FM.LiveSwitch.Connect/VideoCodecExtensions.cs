﻿using System;

namespace FM.LiveSwitch.Connect
{
    static class VideoCodecExtensions
    {
        public static VideoEncoder CreateEncoder(this VideoCodec codec)
        {
            switch (codec)
            {
                case VideoCodec.VP8:
                    return new Vp8.Encoder();
                case VideoCodec.VP9:
                    return new Vp9.Encoder();
                case VideoCodec.H264:
                    return new OpenH264.Encoder();
                default:
                    throw new Exception("Unknown video codec.");
            }
        }

        public static VideoDecoder CreateDecoder(this VideoCodec codec)
        {
            switch (codec)
            {
                case VideoCodec.VP8:
                    return new Vp8.Decoder();
                case VideoCodec.VP9:
                    return new Vp9.Decoder();
                case VideoCodec.H264:
                    return new OpenH264.Decoder();
                default:
                    throw new Exception("Unknown video codec.");
            }
        }

        public static VideoPipe CreatePacketizer(this VideoCodec codec)
        {
            switch (codec)
            {
                case VideoCodec.VP8:
                    return new Vp8.Packetizer();
                case VideoCodec.VP9:
                    return new Vp9.Packetizer();
                case VideoCodec.H264:
                    return new H264.Packetizer();
                default:
                    throw new Exception("Unknown video codec.");
            }
        }

        public static VideoPipe CreateDepacketizer(this VideoCodec codec)
        {
            switch (codec)
            {
                case VideoCodec.VP8:
                    return new Vp8.Depacketizer();
                case VideoCodec.VP9:
                    return new Vp9.Depacketizer();
                case VideoCodec.H264:
                    return new H264.Depacketizer();
                default:
                    throw new Exception("Unknown video codec.");
            }
        }

        public static NullVideoSink CreateNullSink(this VideoCodec codec, bool isPacketized)
        {
            switch (codec)
            {
                case VideoCodec.VP8:
                    return new NullVideoSink(new Vp8.Format() { IsPacketized = isPacketized });
                case VideoCodec.VP9:
                    return new NullVideoSink(new Vp9.Format() { IsPacketized = isPacketized });
                case VideoCodec.H264:
                    return new NullVideoSink(new H264.Format(H264.ProfileLevelId.Default, H264.PacketizationMode.Default) { IsPacketized = isPacketized });
                default:
                    throw new Exception("Unknown video codec.");
            }
        }
    }
}