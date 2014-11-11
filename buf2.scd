s.boot;

(
var size = 1024;


var sinlf = Buffer.alloc(s, size, 1, completionMessage: { |buf| buf.chebyMsg(#[1], asWavetable: false);});
//resettable sine lfo
~rsinosc = {|t_reset = 0, freq = 1, phase = 0, amp = 1, add = 0|
	//

	var ph = Phasor.kr(t_reset, freq / ControlRate.ir, 0.0, 1.0);
	BufRd.kr(1, sinlf, size * (ph + phase), interpolation: 1) * amp + add;
};
)

"/home/paolino/music/WAV/ByKit/Kinoco"

~name = "Kinocorn"
~name = "Acme"
~name= "Derelict"
~name = "Giganorm"
~name = "Hysleria"
~name = "Shrooms"
~name = "test"
(
NoteOnResponder.removeAll;
~buffers = ("/home/paolino/music/WAV/ByKit/"++ ~name ++"/*.wav").pathMatch.collect({ arg i;  Buffer.read(s, i)});
~monobuffers = ("/home/paolino/music/WAV/ByKit/"++ ~name ++"/*.wav").pathMatch.collect({ arg i;
	Buffer.readChannel(s, i,channels:[0])});
//NoteOnResponder({|s,ch,bufnum,v| PlayBuf.ar(2, ~buffers[bufnum], BufRateScale.kr(~buffers[bufnum]), 0, 0 , 0);
)
//~volumes = {Bus.control()}!18

(
~record = {|resetn|

	var start,sig,gsig,env,genv;
	var cgrains,igrains,durgrains,grains,envgrains;
	var freqs;
	var midi,controls,rythms;
	var bufnum,bufnumm;
	midi = {Bus.control()}!40;
	CCResponder.removeAll;

	CCResponder({|s,ch,c,v| midi[c+16].set(v/128)},nil,0);


	Array.fill(8,{arg i;CCResponder({|s,ch,c,v| midi[i].set(v/128)},nil,1,i+21)})
	  ++ Array.fill(8,{arg i;CCResponder({|s,ch,c,v| midi[i+8].set(v/128)},nil,1,i+41)});

	controls = {|n| Lag.kr(In.kr(midi[n]),0.1)};
    freqs = ~lps/16*[2,3,4,5,7,8];
	rythms = 1 - Mix.kr(
			~rsinosc.value
		(In.kr(~reset[resetn]), freqs
			,controls.value([0,1,2,3,4,5])*(2*pi/freqs)
					,controls.value([8,9,10,11,12,13])
				)
			).squared;
	bufnum = Select.kr(controls.value(7)*~buffers.size,~buffers);
	bufnumm = Select.kr(controls.value(7)*~monobuffers.size,~monobuffers);
	envgrains= EnvGen.ar(Env.linen(0.01,0, controls.value(21)*15/125-0.03,(1 - rythms)),In.kr(~ping));
	igrains = Impulse.ar(controls.value(17) * 1000 + 20);
	cgrains = BufDur.kr(bufnumm) *  Phasor.ar(In.kr(~ping),1,controls.value(19),controls.value(20),controls.value(19));
	durgrains = controls.value(28);
	grains = TGrains.ar(2, igrains, bufnumm, 1,cgrains, durgrains);
	gsig =  envgrains * grains;
	start = rythms * BufFrames.kr(bufnum)/(1 + (4 * controls.value(14)));
	sig =   PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), In.kr(~ping), start , 0);
	env = EnvGen.ar(Env.linen(0.01,0.9*15/125-0.03,0.01),In.kr(~ping));
	DelayC.ar( env  * ( controls.value(16)*gsig + (controls.value(15) * sig)),1,controls.value(6))
}
)
(
~lps = 125/15;
~ping = Bus.control(); // main beat
~reset = {Bus.control()}!7;
{Out.kr(~ping,Impulse.kr(~lps))}.play;
{Out.kr(~reset[0],Impulse.kr(~lps/[4,8,16,32,64,128,256]))}.play;
)

{~record.value(5)}.scope;




~monobuffers[1].numChannels;
~monobuffers.size
(
var file = "fr11.wav";
s.recHeaderFormat="wav";
s.recSampleFormat="int32";
s.record(file);
)
s.stopRecording;0
(
~recordk = {|reset,buf|


	var midi,controls,rythms;


	midi = {Bus.control()}!16;
	CCResponder.removeAll;
	Array.fill(8,{arg i;CCResponder({|s,ch,c,v| midi[i].set(v/128)},nil,1,i+21)})
	  ++ Array.fill(8,{arg i;CCResponder({|s,ch,c,v| midi[i+8].set(v/128)},nil,1,i+41)});

	controls = {|n| Lag.kr(In.kr(midi[n]),0.1)};

	rythms = 1 - Mix.kr(
			~rsinosc.value
		(In.kr(reset), ~lps/16*[2,3,4,5,7,8]
					,controls.value([0,1,2,3,4,5])*2*pi
					,controls.value([8,9,10,11,12,13])
				)
			).squared;


	BufWr.kr(rythms,buf,Phasor.ar(In.kr(reset), BufRateScale.kr(buf),0,1000-1));

}
)

~buf = Buffer.alloc(s,10000);
~buf.plot;
{~recordk.value(~reset[3],~buf)}.play;
,