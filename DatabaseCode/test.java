import java.util.*;
import java.io.*;
public class test
{
	public static void main(String args[])throws IOException{
		database test= new database();
		test.readDB();
		test.putDB("Anatomy and Physiology",new byte[]{12, 123, -23, 65});
		System.out.println(Arrays.toString(test.getDB("Anatomy and Physiology")));
		test.putDB("adfasdfasdfasdfasdfasf",new byte[]{123, 99, -23, 23});
		System.out.println(Arrays.toString(test.getDB("Anaeomy an P4hysiology")));
		System.out.println(Arrays.toString(test.getDB("adf sdfasefasdf3dfasf")));
	}
}