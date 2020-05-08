﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;

namespace FM.LiveSwitch.Connect
{
    class Interceptor : Receiver<InterceptOptions, NullAudioSink, NullVideoSink>
    {
        public Task<int> Intercept(InterceptOptions options)
        {
            if (options.AudioPort <= 0 && options.VideoPort <= 0)
            {
                Console.Error.WriteLine("--audio-port and/or --video-port must be specified.");
                return Task.FromResult(1);
            }
            if (options.AudioPort > 0)
            {
                if (!TransportAddress.IsIPAddress(options.AudioIPAddress))
                {
                    Console.Error.WriteLine("--audio-ip-address is invalid.");
                    return Task.FromResult(1);
                }
            }
            if (options.VideoPort > 0)
            {
                if (!TransportAddress.IsIPAddress(options.VideoIPAddress))
                {
                    Console.Error.WriteLine("--video-ip-address is invalid.");
                    return Task.FromResult(1);
                }
            }
            return Receive(options);
        }

        protected override AudioStream CreateAudioStream(ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            if (options.AudioPort == 0)
            {
                return null;
            }

            var track = CreateAudioTrack(remoteConnectionInfo, options);
            var stream = new AudioStream(null, track);
            stream.OnStateChange += () =>
            {
                if (stream.State == StreamState.Closed ||
                    stream.State == StreamState.Failed)
                {
                    track.Destroy();
                }
            };
            return stream;
        }

        protected override VideoStream CreateVideoStream(ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            if (options.VideoPort == 0)
            {
                return null;
            }

            var track = CreateVideoTrack(remoteConnectionInfo, options);
            var stream = new VideoStream(null, track);
            stream.OnStateChange += () =>
            {
                if (stream.State == StreamState.Closed ||
                    stream.State == StreamState.Failed)
                {
                    track.Destroy();
                }
            };
            return stream;
        }

        private AudioTrack CreateAudioTrack(ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            var tracks = new List<AudioTrack>();
            foreach (var codec in ((AudioCodec[])Enum.GetValues(typeof(AudioCodec))).Where(x => x != AudioCodec.Copy))
            {
                tracks.Add(CreateAudioTrack(codec, remoteConnectionInfo, options));
            }
            return new AudioTrack(tracks.ToArray());
        }

        private VideoTrack CreateVideoTrack(ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            var tracks = new List<VideoTrack>();
            foreach (var codec in ((VideoCodec[])Enum.GetValues(typeof(VideoCodec))).Where(x => x != VideoCodec.Copy))
            {
                if (options.DisableOpenH264 && codec == VideoCodec.H264)
                {
                    continue;
                }
                tracks.Add(CreateVideoTrack(codec, remoteConnectionInfo, options));
            }
            return new VideoTrack(tracks.ToArray());
        }

        private AudioTrack CreateAudioTrack(AudioCodec codec, ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            var socket = GetSocket(TransportAddress.IsIPv6(options.AudioIPAddress));
            var remoteEndPoint = new IPEndPoint(IPAddress.Parse(options.AudioIPAddress), options.AudioPort);
            var sink = codec.CreateNullSink(true);
            sink.OnProcessFrame += (frame) =>
            {
                var buffer = frame.LastBuffer;
                if (buffer != null)
                {
                    var dataBuffer = buffer.DataBuffer;
                    if (dataBuffer != null)
                    {
                        socket.SendTo(dataBuffer.Data, dataBuffer.Index, dataBuffer.Length, SocketFlags.None, remoteEndPoint);
                    }
                }
            };
            return new AudioTrack(sink);
        }

        private VideoTrack CreateVideoTrack(VideoCodec codec, ConnectionInfo remoteConnectionInfo, InterceptOptions options)
        {
            var socket = GetSocket(TransportAddress.IsIPv6(options.VideoIPAddress));
            var remoteEndPoint = new IPEndPoint(IPAddress.Parse(options.VideoIPAddress), options.VideoPort);
            var sink = codec.CreateNullSink(true);
            sink.OnProcessFrame += (frame) =>
            {
                var buffer = frame.LastBuffer;
                if (buffer != null)
                {
                    var dataBuffer = buffer.DataBuffer;
                    if (dataBuffer != null)
                    {
                        socket.SendTo(dataBuffer.Data, dataBuffer.Index, dataBuffer.Length, SocketFlags.None, remoteEndPoint);
                    }
                }
            };
            return new VideoTrack(sink);
        }

        private Socket GetSocket(bool ipv6)
        {
            return new Socket(ipv6 ? AddressFamily.InterNetworkV6 : AddressFamily.InterNetwork, SocketType.Dgram, System.Net.Sockets.ProtocolType.Udp);
        }
    }
}