# Home Assistant Assit Pipeline using Whisper.cpp built for Intel OpenVINO capable CPU/iGPUs.

I wanted to add text-to-speach (TTS) and speach-to-text (STT) capability to my home assistant installation and start to break away from Google!  I quickly found HA's documentation on their Assist pipeline and started reading about Piper and Whisper.  I've not included Piper (TTS) here as that was straightforward to deploy using https://github.com/linuxserver/docker-piper.

For STT I opted to use Whisper instead of HA's speach-to-phrase alternative as I want to build a further integration to an offline LLM at a later date.  Whisper's more open ended dialogue type was preferable and I quickly started reading at https://github.com/ggml-org/whisper.cpp.

My goal was for a quick, lightweight container which made efficient use of my server hardware.  Given my container host uses an Intel i5-14500 CPU I wanted to try and exploit the iGPU via Intel's OpenVINO framework.  After searching a little I found https://github.com/tannisroot/wyoming-whisper-cpp-intel-gpu-docker which was a great start for me.  Whist Aleksandr's code works fine I was a little bothered by the resulting image file being over 10GB and this didn't tick my 'lightweight' box.  Also his solution uses Intel's oneAPI SYCL verse my unqualified aspiration to use OpenVINO!

So why bother with this alternative?
- [x] Uses OpenVINO (think I've mentioned this!)
- [x] Successfully offloads to my CPU's iGPU
- [x] Using the small.en model my container inferences very quickly and uses 1GB RAM
- [x] The docker image built is substantially smaller at @1.2Gb excluding the model
- [ ] Doesn't allow you to set the container process user yet
- [ ] Could be a bit cumbersome in dealing with the OpenVINO build dependencies
- [ ] Requires the images to be rebuilt to switch between models which could be slow on some hardware

As you can see there are some to-do's and I'm no coder, this is all amateur so you've been warned!