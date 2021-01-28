

(
~b1 = Buffer.read(s, "Birds Buffer path");
 {

	{

b = Dictionary.new;
PathName("Buffer path").entries.do{
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	);
};



SynthDef.new(\glitch1, {
	arg atk=0.5, sus=1, rel=1, rate=1, buf=0, freq=400, rq=0.5, pan=0.0, amp=1, bpfmix=0, startpos=0, mix=1, room=0.5, damp=0.5, out=0, pitchRatio=1;
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction: 2);
	sig = PlayBuf.ar(2, buf, rate, startPos:startpos);
	sig = PitchShift.ar(sig, 0.2, pitchRatio, LFNoise0.kr(0.1).linlin(-1, 1, 0, 1), LFNoise0.kr(0.1).linlin(-1, 1, 0, 1));
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig!2);
}
).add;

SynthDef.new(\glitch2, {
	arg atk=0.5, sus=1, rel=1, rate=1, buf=0, freq=400, rq=0.5, pan=0.0, amp=1, bpfmix=0, startpos=0, mix=1, room=0.5, damp=0.5, out=0, pitchRatio=1, amp1=1;
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction: 2);
	sig = PlayBuf.ar(2, buf, rate, startPos:startpos);
	sig = FreqShift.ar(sig, LFNoise0.kr(5.5, 10000), LFNoise0.kr(0.1, 1000), [10,10]);
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan, amp1);
	Out.ar(out, sig!2);
}
).add;

SynthDef.new(\glitch3, {
	arg atk=0.5, sus=1, rel=1, rate=1, buf=0, freq=400, rq=0.5, pan=0.0, amp=1, bpfmix=0, startpos=0, mix=1, room=0.5, damp=0.5, out=0, pitchRatio=1, amp1=1, freqshift=100;
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction: 2);
	sig = PlayBuf.ar(2, buf, rate, startPos:startpos);
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = FreqShift.ar(sig, LFNoise0.kr(100, freqshift), LFNoise0.kr(0.1, 1000), [10,10]);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan, amp1);
	Out.ar(out, sig!2);
}
).add;

SynthDef.new(\bufbird, {
	arg atk=0.5, sus=1, rel=1, rate=1, buf=0, freq=400, rq=0.5, pan=0.0, amp=1, bpfmix=1, startpos=0, overdrive=1, oct=1, mix=0.33, room=0.5, damp=0.5, out=0;
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction: 2);
	sig = PlayBuf.ar(2, buf, rate, startPos:startpos);
	sig = XFade2.ar(sig, BPF.ar(sig, freq * oct, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = FreeVerb.ar(sig, mix, room, damp);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig!2);
}
).add;

SynthDef.new(\bufquake,{
	arg atk=0.5, sus=1, rel=1, rate=1, buf=0, freq=400, rq=0.5, pan=0.0, amp=1, bpfmix=1, startpos=0, mix=0.33, room=0.5, damp=0.5, detune=3, overdrive=1, pitch=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction: 2);
			sig = Mix(PlayBuf.ar(2, buf, rate, startPos:startpos));
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq, 1/rq.sqrt), bpfmix*2-1);
	sig = PitchShift.ar(sig, 0.2, pitch);
	sig = (sig*overdrive).softclip * env;
	sig = FreeVerb.ar(sig, mix, room, damp);

	sig =
	Compander.ar(sig, sig,
        thresh: 0.5,
        slopeBelow: 1,
        slopeAbove: 0.5,
        clampTime: 0.01,
        relaxTime: 0.01
    );
	sig = Pan2.ar(sig, 0, amp);
	Out.ar(out, sig);
}
).add;


~glitch1 = Pbind(
	\instrument, \glitch1,
	\dur, Pexprand(0.01, 0.1, 100),
	\buf, Pwrand(b[\Percussive][(0..6)],[1,2,2,1,2,0.5,1],inf),
	\startpos, Pwhite(10, 100, inf),
	\freq, Pexprand(1000, 15000),
	\rate, Pxrand([-3, -2, -1.5, 1.5, 2, 3], inf),
	\rq, Pwhite(0.001, 0.2, inf)/400,
	\atk, Pexprand(0.01, 0.3),
	\sus, Pexprand(0.01, 0.3),
	\rel, Pexprand(0.01, 0.3),
	\mix, Pfunc({rrand(0.01,1)}),
	\pitchRatio, Pexprand(1, 1000, inf),
	\amp, 2,
);

~g2 = Pbind(
	\instrument, \glitch2,
	\dur, Ppoisson(rrand(0.001, 10), rrand(2, 10)),
	\buf, Pwrand(b[\Percussive][(0..6)],[1,2,2,1,2,0.5,1],inf),
	\startpos, Pwhite(1000, 100000, inf),
	\freq, Pexprand(1000, 15000),
	\rate, Pxrand([-3, -2, -1.5, 1.5, 2, 3], inf),
	\rq, Pwhite(0.001, 0.2, inf)/400,
	\atk, Pexprand(0.1, 0.8),
	\sus, Pexprand(0.1, 0.8),
	\rel, Pexprand(0.2, 0.5),
	\mix, Pfunc({rrand(0.01,1)}),
	\freq, Pfunc({rrand(400, 2000)}),
	\amp, 0.1,
);


~glitch3 = Pbind(
	\instrument, \glitch3,
	\dur, Pgeom(rrand(3, 7), rrand(0.7, 0.9), rrand(5, 200)),
	\buf, Pwrand(b[\Percussive][(0..6)],[1,2,2,1,2,0.5,1],inf),
	\startpos, Pwhite(10, 100, inf),
	\freq, Pexprand(1000, 15000),
	\rate, Pxrand([-3, -2, -1.5, 1.5, 2, 3], inf),
	\rq, Pwhite(0.001, 0.2, inf)/400,
	\atk, Pexprand(0.01, 0.3),
	\sus, Pexprand(0.01, 0.3),
	\rel, Pexprand(0.01, 0.3),
	\mix, Pfunc({rrand(0.01,1)}),
	\freq, Pexprand(rrand(300, 500), rrand(1000, 2000)),
	\freqshift, Pexprand(100, 10000, inf),
	\amp, 0.2,
);


~g4 = Pbind(
	\instrument, \glitch2,
	\dur, Ppoisson(rrand(0.001, 0.5), rrand(5, 20)),
	\buf, Pwrand(b[\Percussive][(0..6)],[1,2,2,1,2,0.5,1],inf),
	\startpos, Pwhite(1000, 100000, inf),
	\freq, Pexprand(1000, 15000),
	\rate, Pxrand([-20, -10, 10, 20], inf),
	\rq, Pwhite(0.001, 0.2, inf)/400,
	\atk, Pexprand(0.1, 0.8),
	\sus, Pexprand(0.1, 0.8),
	\rel, Pexprand(0.2, 0.5),
	\mix, Pfunc({rrand(0.01,1)}),
	\freq, Pfunc({rrand(400, 2000)}),
	\amp, 0.1,
);


~birds1 = Pbind(
	\instrument, \bufbird,
    \buf,~b1.bufnum,
	\dur, Pexprand(1.5, 3.5, inf),
	\atk, Pexprand(2.5, 3.5, inf),
	\sus, Pexprand(2.5, 2.5, inf),
	\rel, Pexprand(1.5, 2.5, inf),
	\startpos, Pexprand(1000, ~b1.numFrames, inf),
	\bpfmix, 1,
	\freq, Pxrand([54, 56, 58, 59, 61, 63].midicps, inf),
	\oct, Pxrand([1, 2], inf),
	\harmonic, Pexprand(1, 80, inf),
	\rq, Pexprand(0.85, 0.99, inf)/200,
	\rate, Pexprand(0.85, 1, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\mix, Pexprand(0.3, 0.7, inf),
	\room, Pexprand(0.4, 0.7, inf),
	\damp, Pexprand(0.3, 0.8, inf),
	\amp, 8,
	);

~birds3 = Pbind(
	\instrument, \bufbird,
    \buf,~b1.bufnum,
	\dur, Pexprand(1.5, 3.5, inf),
	\atk, Pexprand(2.5, 3.5, inf),
	\sus, Pexprand(2.5, 2.5, inf),
	\rel, Pexprand(1.5, 2.5, inf),
	\startpos, Pexprand(1000, ~b1.numFrames, inf),
	\bpfmix, 1,
	\freq, Pxrand([48, 50, 52, 53, 55, 57, 59].midicps, inf),
	\oct, Pxrand([1, 2, 3], inf),
	\oct, Pxrand([1, 2], inf),
	\harmonic, Pexprand(1, 80, inf),
	\rq, Pexprand(0.85, 0.99, inf)/200,
	\rate, Pexprand(0.85, 1, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\mix, Pexprand(0.3, 0.7, inf),
	\room, Pexprand(0.4, 0.7, inf),
	\damp, Pexprand(0.3, 0.8, inf),
	\amp, 8,
	);


~birds2 = Pbind(
	\instrument, \bufbird,
    \buf,~b1.bufnum,
	\dur, Pexprand(1.5, 3.5, inf),
	\atk, Pexprand(2.5, 4, inf),
	\sus, Pexprand(3.5, 4.2, inf),
	\rel, Pexprand(2.0, 3.0, inf),
	\startpos, Pexprand(1000, ~b1.numFrames, inf),
	\bpfmix, 1,
	\freq, Pexprand(120, 500, inf).round(55),
	\harmonic, Pexprand(1, 80, inf),
	\rq, Pexprand(0.85, 0.99, inf)/400,
	\rate, Pexprand(0.9, 1, inf),
	\mix, Pexprand(0.3, 0.7, inf),
	\room, Pexprand(0.4, 0.7, inf),
	\damp, Pexprand(0.3, 0.8, inf),
	\pan, Pwhite(-1, 1, inf),
	\amp, Pwhite(5, 8, inf)
	);

~birds4 = Pbind(
	\instrument, \bufbird,
    \buf,~b1.bufnum,
	\dur, Pexprand(1.5, 3.5, inf),
	\atk, Pexprand(2.5, 4, inf),
	\sus, Pexprand(3.5, 4.2, inf),
	\rel, Pexprand(2.0, 3.0, inf),
	\startpos, Pexprand(1000, ~b1.numFrames, inf),
	\bpfmix, 1,
	\freq, Pexprand(150, 800, inf).round(20),
	\harmonic, Pexprand(1, 150, inf),
	\rq, Pexprand(0.85, 0.99, inf)/400,
	\rate, Pexprand(0.9, 1, inf),
	\mix, Pexprand(0.3, 0.7, inf),
	\room, Pexprand(0.4, 0.7, inf),
	\damp, Pexprand(0.3, 0.8, inf),
	\pan, Pwhite(-1, 1, inf),
	\amp, Pwhite(5, 8, inf),
);

~bassSounds = (
			~buffers = b[\Lowfreq];
~attackTimes = [rrand(2.0, 4.0), rrand(8.0, 10), rrand(0.5, 2), rrand(8.0, 10), rrand(2, 3.0), rrand(1.0, 2.0), rrand(2.0, 4.0), rrand(1.5, 2.5)];
~susTimes = [rrand(1.5, 2.0), rrand(2.0, 3), rrand(1.0, 2.0), rrand(3.0, 5.0), rrand(0.5, 2), rrand(0.5, 1.5), rrand(2.0, 2.5), rrand(1.5, 2.0)];
~relTimes = [rrand(2.0, 3.0), rrand(4.0, 6.0), rrand(0, 1.0), rrand(4.0, 6.0), rrand(0, 1.5), rrand(1.0,1.5), rrand(3.0, 4.0), rrand(1.0, 2.0)];
~amp = [0.6, 0.9, 0.1, 2.0, 0.8, 0.8, 1, 0.8];
	~durtimes = [rrand(0.5, 1.0), rrand(5.0, 6.0), rrand(1.0, 2.0), rrand(5.0, 6.0), rrand(1.0, 2.0), rrand(2.5, 3.5), rrand(2.0, 4.0), rrand(1.0, 2.0)];
	~startpos = [rrand(10, 10000), rrand(1, 5000), rrand(1, 5000), rrand(10, 10000), rrand(100, 200), rrand(10, 100), 1, rrand(10, 300)];
	Pbind(
	\instrument, \bufquake,
	\bpfmix, Pexprand(0.5, 0.8, inf),
	\choice, Pwrand(Array.series(~buffers.size), Array.fill(~buffers.size, {rrand(0.5, 1)}),inf),
	\buf,  Pwrand(b[\Lowfreq],[1,4,0.5,3,1.5,2,2,1].normalizeSum ,inf).postln,
	\atk, Pindex(~attackTimes, Pkey(\choice), inf),
	\sus, Pindex(~susTimes, Pkey(\choice), inf),
	\rel, Pindex(~relTimes, Pkey(\choice), inf),
	\startpos, Pindex(~startpos, Pkey(\choice), inf),
	\freq, Pxrand([32, 34, 36, 38, 40, 42].midicps, inf),
	\amp, Pindex(~amp, Pkey(\choice), inf) * 1.5,
	\harmonic, Pexprand(1, 5, inf),
	\rq, Pexprand(0.9, 0.99, inf)/10,
	\dur, Pindex(~durtimes, Pkey(\choice), inf),
	\mix, Pexprand(0.9, 0.99, inf),
	\room, Pexprand(0.4, 0.99, inf),
	\damp, Pexprand(0.1, 0.9, inf),
	/*\pan, Pwhite(0, 0, inf),*/
);


);

Ndef(\g1, ~g1).play;
Ndef(\glitch2, ~glitch2).play;
Ndef(\g3).play;
Ndef(\glitch4).play;

s.record;
Ndef(\birds1, {}).play;
Ndef(\birds2, {}).play;
Ndef(\birds3, {}).play;
Ndef(\birds4, {}).play;

Ndef(\birds1).fadeTime = 1;
Ndef(\birds2).fadeTime = 1;
Ndef(\birds3).fadeTime = 1;
Ndef(\birds4).fadeTime = 1;

~net = NetAddr("localhost", 7400);

Ndef(\oscToMaxb1, {arg samplingRate=10;
	var sig;
	sig = Ndef(\birds1).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 1, sig.abs * 100);
});

OSCdef(\getSig1, {arg msg;
	if(msg[2] == 1, {
	~net.sendMsg("sc1", msg[3]);
	});
}, '/tr', s.addr);


////BIRDS2

Ndef(\oscToMax2b2, {arg samplingRate=10;
	var sig;
	sig = Ndef(\birds2).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 2, sig.abs * 100);
});

OSCdef(\getSigb2, {arg msg;
	if(msg[2] == 2, {
	~net.sendMsg("sc2", msg[3]);
	});
}, '/tr', s.addr);


////BIRDS3


Ndef(\oscToMaxb3, {arg samplingRate=10;
	var sig;
	sig = Ndef(\birds3).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 3, sig.abs * 100);
});



OSCdef(\getSigb3, {arg msg;
	if(msg[2] == 3, {
	~net.sendMsg("sc3", msg[3]);
	});
}, '/tr', s.addr);


////BIRDS4

Ndef(\oscToMaxb4, {arg samplingRate=10;
	var sig;
	sig = Ndef(\birds4).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 4, sig.abs * 100);
});


OSCdef(\getSig4, {arg msg;
	if(msg[2] == 4, {
	~net.sendMsg("sc4", msg[3]);
	});
}, '/tr', s.addr);

////BASSMESSAGE

Ndef(\oscToMaxbass, {arg samplingRate=10;
	var sig;
	sig = Ndef(\bassSounds).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 9, sig.abs * 100);
});


OSCdef(\getSig9, {arg msg;
	if(msg[2] == 9, {
	~net.sendMsg("sc9", msg[3]);
	});
}, '/tr', s.addr);


Ndef(\oscToMax7, {arg samplingRate=10;
	var sig;
	sig = Ndef(\g1).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 7, sig.abs * 10000);
});

OSCdef(\getSig7, {arg msg;
	if(msg[2] == 7, {
	~net.sendMsg("sc7", msg[3]);
	});
}, '/tr', s.addr);


////GLITCH2
Ndef(\oscToMax5, {arg samplingRate=10;
	var sig;
	sig = Ndef(\glitch2).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 5, sig.abs * 10000);
});


OSCdef(\getSig5, {arg msg;
	if(msg[2] == 5, {
	~net.sendMsg("sc5", msg[3]);
	});
}, '/tr', s.addr);


////GLITCH3


Ndef(\oscToMax8, {arg samplingRate=10;
	var sig;
	sig = Ndef(\g3).ar;
	SendTrig.kr(Impulse.kr(samplingRate), 8, sig.abs * 10000);
});


OSCdef(\getSig8, {arg msg;
	if(msg[2] == 8, {
	~net.sendMsg("sc8", msg[3]);
	});
}, '/tr', s.addr);


////GLITCH4


Ndef(\oscToMax6, {arg samplingRate=10;
	var sig;
	sig = Ndef(\glitch4).ar; //double send
	SendTrig.kr(Impulse.kr(samplingRate), 6, sig.abs * 10000);
});

OSCdef(\getSig6, {arg msg;
	if(msg[2] == 6, {
	~net.sendMsg("sc6", msg[3]);
	});
}, '/tr', s.addr);

0.1.yield;
HID.findAvailable;
1.yield;
~myhid1 = HID.openPath("USB_0079_0011_14200000");
~myhid2 = HID.openPath("USB_0079_0011_14100000");
0.5.yield;

~myhid1.elements.do{|item|

	item.action = { |...args|
		var idVal, val;

		"matt1".postln;

		idVal = args[1].usage;
		val = args[0];

		[idVal, val].postln;

			case
	{idVal == 1} {
		if(val == 1, {"1 is On".postln;
			Ndef(\g1, ~glitch1);
		}, {"1 is Off".postln;
			Ndef(\g1, {});
	}); }
	{idVal == 4} {
		if(val == 1, {"4 is On".postln;
			Ndef(\glitch2, ~g2);
		}, {"4 in Off".postln;
			Ndef(\glitch2, {});
		});
	}
	{idVal == 2} {
		if(val == 1, {"2 is On".postln;
			Ndef(\g3, ~glitch3);
		}, {"2 in Off".postln;
			Ndef(\g3, {});
		});
	}
	{idVal == 3} {
		if(val == 1, {"3 is On".postln;
			Ndef(\glitch4, ~g4);
		}, {"3 in Off".postln;
			Ndef(\glitch4, {});
		});
	}
	{idVal == 5} {
		if(val == 1, {"3 is On".postln;
			Ndef(\glitch2, ~g2);
		}, {"3 in Off".postln;
			Ndef(\glitch2, {});
		});
	}
	{idVal == 6} {
		if(val == 1, {"3 is On".postln;
			Ndef(\g1, ~glitch1);
		}, {"3 in Off".postln;
			Ndef(\g1, {});
		});
	}
	{idVal == 7} {
		if(val == 1, {"3 is On".postln;
			Ndef(\g3, ~glitch3);
		}, {"3 in Off".postln;
			Ndef(\g3, {});
		});
	}
	{idVal == 8} {
		if(val == 1, {"3 is On".postln;
			Ndef(\glitch4, ~g4);
		}, {"3 in Off".postln;
			Ndef(\glitch4, {});
		});
	};

		// args.postln;


};};

~myhid2.elements.do{|item|


	item.action = { |...args|
		var idVal, val;

		"matt2".postln;

		idVal = args[1].usage;
		val = args[0];

		[idVal, val].postln;

	case
	{idVal == 1} {
		if(val == 1, {"1 is On".postln;
			Ndef(\birds1, ~birds1);
		}, {"1 is Off".postln;
			Ndef(\birds1, {});
	}); }
	{idVal == 4} {
		if(val == 1, {"4 is On".postln;
			Ndef(\birds2, ~birds2);
		}, {"4 in Off".postln;
			Ndef(\birds2, {});
		});
	}
	{idVal == 2} {
		if(val == 1, {"2 is On".postln;
			Ndef(\birds3, ~birds3);
		}, {"2 in Off".postln;
			Ndef(\birds3, {});
		});
	}
	{idVal == 3} {
		if(val == 1, {"3 is On".postln;
			Ndef(\birds4, ~birds4);
		}, {"3 in Off".postln;
			Ndef(\birds4, {});
		});
	}
	{idVal == 8} {
		if(val == 1, {"1 is On".postln;
			Ndef(\birds3, ~birds3);
		}, {"1 is Off".postln;
			Ndef(\birds3, {});
	}); }
	{idVal == 5} {
		if(val == 1, {"4 is On".postln;
			Ndef(\birds1, ~birds1);
		}, {"4 in Off".postln;
			Ndef(\birds1, {});
		});
	}
	{idVal == 6} {
		if(val == 1, {"2 is On".postln;
			Ndef(\birds4, ~birds4);
		}, {"2 in Off".postln;
			Ndef(\birds4, {});
		});
	}
	{idVal == 7} {
		if(val == 1, {"3 is On".postln;
			Ndef(\birds2, ~birds2);
		}, {"3 in Off".postln;
			Ndef(\birds2, {});
		});
	}


};
};

"done".postln;
Ndef(\bassSounds, ~bassSounds).play;

}.fork;
});
)