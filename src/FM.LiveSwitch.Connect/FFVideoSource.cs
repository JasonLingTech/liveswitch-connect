﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FM.LiveSwitch.Connect
{
    class FFVideoSource : VideoSource
    {
        static readonly ILog _Log = Log.GetLogger(typeof(FFVideoSource));

        public override string Label
        {
            get { return "FFmpeg Video Source"; }
        }

        public string PipeName { get; private set; }

        public event Action0 OnPipeConnected;

        private NamedPipe _Pipe;

        private int _HeaderWidth;
        private int _HeaderHeight;
        private double _HeaderFrameRate;
        private string _HeaderInterlacing;
        private double _HeaderPixelAspectRatio;
        private string _HeaderColourSpace;
        private string _HeaderComment;

        private int _Width;
        private int _Height;

        public FFVideoSource(string pipeName)
            : base(VideoFormat.I420)
        {
            PipeName = pipeName;
        }

        protected override Future<object> DoStart()
        {
            var promise = new Promise<object>();
            try
            {
                _Pipe = new NamedPipe(PipeName, true);
                _Pipe.OnConnected += () =>
                {
                    OnPipeConnected?.Invoke();
                };
                _Pipe.OnReadDataBuffer += (dataBuffer) =>
                {
                    RaiseFrame(new VideoFrame(new VideoBuffer(_Width, _Height, dataBuffer, OutputFormat)));
                };

                var ready = _Pipe.WaitForConnectionAsync();

                Task.Run(async () =>
                {
                    await ready;

                    ReadStreamHeader();

                    var headerParams = new List<string>();
                    if (_HeaderWidth != 0)
                    {
                        headerParams.Add($"Width={_HeaderWidth}");
                    }
                    if (_HeaderHeight != 0)
                    {
                        headerParams.Add($"Height={_HeaderHeight}");
                    }
                    if (_HeaderFrameRate != 0)
                    {
                        headerParams.Add($"FrameRate={_HeaderFrameRate}");
                    }
                    if (_HeaderInterlacing != null)
                    {
                        headerParams.Add($"Interlacing={_HeaderInterlacing}");
                    }
                    if (_HeaderPixelAspectRatio != 0)
                    {
                        headerParams.Add($"PixelAspectRatio={_HeaderPixelAspectRatio}");
                    }
                    if (_HeaderColourSpace != null)
                    {
                        headerParams.Add($"ColourSpace={_HeaderColourSpace}");
                    }
                    if (_HeaderComment != null)
                    {
                        headerParams.Add($"Comment={_HeaderComment}");
                    }
                    _Log.Debug(Id, $"Stream Header => {string.Join(", ", headerParams)}");

                    _Pipe.StartReading(ReadFrameHeader);
                });

                promise.Resolve(null);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
            }
            return promise;
        }

        protected override Future<object> DoStop()
        {
            var promise = new Promise<object>();
            try
            {
                Task.Run(async () =>
                {
                    try
                    {
                        await _Pipe.StopReading();
                        await _Pipe.DestroyAsync();

                        promise.Resolve(null);
                    }
                    catch (Exception ex)
                    {
                        promise.Reject(ex);
                    }
                });
                promise.Resolve(null);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
            }
            return promise;
        }

        private void ReadStreamHeader()
        {
            // YUV4MPEG2
            if (Read8() != 'Y' ||
                Read8() != 'U' ||
                Read8() != 'V' ||
                Read8() != '4' ||
                Read8() != 'M' ||
                Read8() != 'P' ||
                Read8() != 'E' ||
                Read8() != 'G' ||
                Read8() != '2')
            {
                throw new Exception("Invalid stream signature.");
            }

            var c = Read8();
            if (c != '\n' && c != ' ')
            {
                throw new Exception("Malformed stream header.");
            }

            while (c != '\n')
            {
                c = Read8();
                if (c == 'W')
                {
                    var s = ReadParameter(out c);

                    if (!ParseAssistant.TryParseIntegerValue(s, out _HeaderWidth))
                    {
                        throw new Exception("Invalid stream header width.");
                    }
                }
                else if (c == 'H')
                {
                    var s = ReadParameter(out c);

                    if (!ParseAssistant.TryParseIntegerValue(s, out _HeaderHeight))
                    {
                        throw new Exception("Invalid stream header height.");
                    }
                }
                else if (c == 'F')
                {
                    var s = ReadParameter(out c);
                    var split = s.Split(':');
                    if (split.Length != 2)
                    {
                        throw new Exception("Invalid stream header frame rate.");
                    }

                    if (!ParseAssistant.TryParseIntegerValue(split[0], out var num) ||
                        !ParseAssistant.TryParseIntegerValue(split[1], out var den))
                    {
                        throw new Exception("Invalid stream header frame rate.");
                    }

                    _HeaderFrameRate = (double)num / den;
                }
                else if (c == 'I')
                {
                    _HeaderInterlacing = ReadParameter(out c);
                }
                else if (c == 'A')
                {
                    var s = ReadParameter(out c);
                    var split = s.Split(':');
                    if (split.Length != 2)
                    {
                        throw new Exception("Invalid stream header pixel aspect ratio.");
                    }

                    if (!ParseAssistant.TryParseIntegerValue(split[0], out var num) ||
                        !ParseAssistant.TryParseIntegerValue(split[1], out var den))
                    {
                        throw new Exception("Invalid stream header pixel aspect ratio.");
                    }

                    _HeaderPixelAspectRatio = (double)num / den;
                }
                else if (c == 'C')
                {
                    _HeaderColourSpace = ReadParameter(out c);
                }
                else if (c == 'X')
                {
                    _HeaderComment = ReadParameter(out c);
                }
                else
                {
                    var p = Utf8.Decode(new[] { (byte)c });
                    var s = ReadParameter(out c);
                    _Log.Warn(string.Format("Ignoring stream header parameter {0}{1}", p, s));
                }
            }
        }

        private int ReadFrameHeader()
        {
            if (Read8() != 'F' ||
                Read8() != 'R' ||
                Read8() != 'A' ||
                Read8() != 'M' ||
                Read8() != 'E')
            {
                throw new Exception("Invalid frame signature.");
            }

            var c = Read8();
            if (c != '\n' && c != ' ')
            {
                throw new Exception("Malformed frame header.");
            }

            _Width = _HeaderWidth;
            _Height = _HeaderHeight;
            while (c != '\n')
            {
                c = Read8();
                if (c == 'W')
                {
                    var s = ReadParameter(out c);

                    if (!ParseAssistant.TryParseIntegerValue(s, out _Width))
                    {
                        throw new Exception("Invalid frame header width.");
                    }
                }
                else if (c == 'H')
                {
                    var s = ReadParameter(out c);

                    if (!ParseAssistant.TryParseIntegerValue(s, out _Height))
                    {
                        throw new Exception("Invalid frame header height.");
                    }
                }
                else
                {
                    var p = Utf8.Decode(new[] { (byte)c });
                    var s = ReadParameter(out c);
                    _Log.Warn(string.Format("Ignoring frame header parameter {0}{1}", p, s));
                }
            }

            return _Width * _Height * 3 / 2;
        }

        private readonly DataBuffer _Single = DataBuffer.Allocate(1);

        private int Read8()
        {
            return _Pipe.Read(_Single).Read8(0);
        }

        private string ReadParameter(out int c)
        {
            var s = string.Empty;
            c = Read8();
            while (c != '\n' && c != ' ')
            {
                s += Utf8.Decode(new[] { (byte)c });
                c = Read8();
            }
            return s;
        }
    }
}