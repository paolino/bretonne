s.boot;
(
{
    var in, chain;
    in = VarSaw.ar(200);
    chain = FFT({ LocalBuf(2048) } ! 2, in); // we need two buffers for stereo input.
    // moves in and out of freeze
    chain = PV_MagFreeze(chain, SinOsc.kr(1) );
    0.5 * IFFT(chain);
}.play;
)
c = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
x = {
  var in, numFrames=2048, chain, v;
  in = PlayBuf.ar(1, c, loop: 1);
  chain = FFT(LocalBuf(numFrames), in);

  chain = chain.pvcalc(numFrames, {|mags, phases|
      /* Play with the mags and phases, then return them */
      [mags, phases].flop.clump(2).flop.flatten
  }, tobin: 250);

  Out.ar(0, 0.5 * IFFT(chain).dup);
}.play;
)
x.free; c.free;
ServerOptions.memSize=32000;
d = Buffer.read(s,"/usr/local/share/renoise-3.0.0/Library/Samples/Kicks/dh_kick_mid_goodthump.flac")
b=Bus.control(s);
c=Bus.control(s);
(
SynthDef(\basso,
{ arg freq=200,width=0.5;
		var inA, chainA, inB, chainB, chain;
	inA =  VarSaw.ar(freq,0,width);
    inB = PlayBuf.ar(1, d, BufRateScale.kr(d));
    chainA = FFT(LocalBuf(2048), inA);
    chainB = FFT(LocalBuf(2048), inB);
    chain = PV_MagMul(chainB, chainA); // writes into bufferA
		Out.ar(0,0.1 * IFFT(chain).dup);
	}).send;
)
x=Synth(\basso);
b.set(51);
MIDIIn.connect;
MIDIdef.cc(\cb,{arg ...args; b.set(args[0])},21,1);
MIDIdef.cc(\cc,{arg ...args; c.set(args[0]/128)},22,1);
MIDIdef.noteOn(\test4, {arg ...args; Synth(\basso,[\freq,args[1].midicps,\width,args[0]/128])},(0..127),0); // match any noteOn