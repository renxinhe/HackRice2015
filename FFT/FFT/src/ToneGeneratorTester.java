import java.io.ByteArrayInputStream;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.LineUnavailableException;


public class ToneGeneratorTester {
	/** Generates a tone, and assigns it to the Clip. */
	public void generateTone()
	    throws LineUnavailableException {
	    if ( clip!=null ) {
	        clip.stop();
	        clip.close();
	    } else {
	        clip = AudioSystem.getClip();
	    }
	    boolean addHarmonic = harmonic.isSelected();

	    int intSR = ((Integer)sampleRate.getSelectedItem()).intValue();
	    int intFPW = framesPerWavelength.getValue();

	    float sampleRate = (float)intSR;

	    // oddly, the sound does not loop well for less than
	    // around 5 or so, wavelengths
	    int wavelengths = 20;
	    byte[] buf = new byte[2*intFPW*wavelengths];
	    AudioFormat af = new AudioFormat(
	        sampleRate,
	        8,  // sample size in bits
	        2,  // channels
	        true,  // signed
	        false  // bigendian
	        );

	    int maxVol = 127;
	    for(int i=0; i<intFPW*wavelengths; i++){
	        double angle = ((float)(i*2)/((float)intFPW))*(Math.PI);
	        buf[i*2]=getByteValue(angle);
	        if(addHarmonic) {
	            buf[(i*2)+1]=getByteValue(2*angle);
	        } else {
	            buf[(i*2)+1] = buf[i*2];
	        }
	    }

	    try {
	        byte[] b = buf;
	        AudioInputStream ais = new AudioInputStream(
	            new ByteArrayInputStream(b),
	            af,
	            buf.length/2 );

	        clip.open( ais );
	    } catch(Exception e) {
	        e.printStackTrace();
	    }
	}
	
	
}
