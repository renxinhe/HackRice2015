// The FollowInstrument just plays a continuous tone, but it will change to a new
// frequency after a specified delay.

// Every instrument must implement the Instrument interface so 
// playNote() can call the instrument's methods.
class FollowInstrument implements Instrument
{
  // create all variables that must be used throughout the class
  Oscil sineOsc;
  Line freqLine;
  ADSR adsr;
  AudioOutput out;
  float offset;
  
  // The class constructor specifies the amplitude, frequency, frequency offset,
  // frequency alignment delay, and audioOutput.
  FollowInstrument( float amplitude, float frequency, float offset, float alignDelay, AudioOutput out )
  {
    // equate class variables to constructor variables as necessary
    this.out = out;
    this.offset = offset;
    
    // set the frequency to a lower fifth
    frequency *= 0.75;

    // create new instances of any UGen objects as necessary
    sineOsc = new Oscil( frequency, amplitude, Waves.SINE );
    adsr = new ADSR( 1.0, 0.1, 0.1, 1.0, 0.1 );
    freqLine = new Line( alignDelay, frequency, frequency );

    // patch everything together up to the final output
    // frequency is controlled by a line object so the frequency change won't be too abrupt.
    freqLine.patch( sineOsc.frequency );
    sineOsc.patch( adsr );
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // patch the adsr all the way to the output 
    adsr.patch(out);
    // turn on the ADSR
    adsr.noteOn();
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    // turn off adsr, which cause the release to begin
    adsr.noteOff();
    // after the release is over, unpatch from the out
    adsr.unpatchAfterRelease( out );
  }
 
  // set a new frequency
  void setNewFreq( float newFreq )
  {
    // a little debugging output never hurt anybody, right?
    println( "Follow new freq = " + newFreq );
    // set a new ending amplitude for the frequency line
    freqLine.setEndAmp( 0.5*newFreq + offset );
    // and reactivate the frequency line.
    freqLine.activate();
  }
  
  // get the current frequency from this instrument
  float getCurrentFrequency()
  {
    // All UGens have a getLastValues() method to get the last values
    // generated by the UGen.  It is returned as an array of floats
    // which for now is only one or two values long. 
    float tmp[] = freqLine.getLastValues();
    if ( tmp.length > 0 )
    {
      return tmp[ 0 ];
    }
    return 0;
  }
}
