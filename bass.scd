
MIDIIn.connectAll
(
var b = 0;
var c=0;
var le=0;


MIDIFunc.cc({arg ...args;b=args[0]/127;}, 1); // match cc 1

MIDIFunc.cc({arg ...args;c = args[0]/127;}, 2); // match cc 1

MIDIFunc.cc({arg ...args;le = args[0]/127;}, 3); // match cc 1

MIDIFunc.noteOn({arg ...args; Synth.new("bass",[\freq,args[1].midicps,\touch,args[0]/127,\in,b.value,\sin,c.value,\le,le]);
   },(1..127),0); // match any noteOn


SynthDef(
    "bass",                 // the name of the synthdef
    {                     // the ugenGraphFunc with actual code

        arg freq,touch,in,sin,le;
        Out.ar(
            0,touch*
			EnvGen.kr(Env.perc (releaseTime:(0.1 + in)/touch), doneAction: 2)*Mix.ar([0.6*Pulse.ar(freq, 0.1+(le),0.7),SinOsc.ar(freq*1.01,0,sin)])
        )
    }
).load(s);
)

