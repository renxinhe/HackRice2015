import java.util.Arrays;
import ddf.minim;

import org.jtransforms.fft.*;
import org.jtransforms.utils.IOUtils;

public class FFTTester {
	public static void main (String[] args) {
		DoubleFFT_1D dft = new DoubleFFT_1D(12);
		final int NUM_SAMPLE = 12;
		double[] testIn = new double[2 * NUM_SAMPLE];
//		double[] testIn = {-0.03480425839330703, 0, 0.07910192950176387, 0, 0.7233322451735928, 0, 0.1659819820667019, 0};
		int index = 0;
		for (double i = 0; i <= 2 * Math.PI; i += 2 * Math.PI / NUM_SAMPLE) {
			testIn[index++] = 2 * Math.cos(i);
			testIn[index++] = 0;
		}
		dft.complexForward(testIn);
//		IOUtils.showReal_1D(testIn, "Real");
		IOUtils.showComplex_1D(testIn, "Complex");
//		dft.complexInverse(testIn, false);
//		IOUtils.showComplex_1D(testIn, "Inversion");
	}
}
