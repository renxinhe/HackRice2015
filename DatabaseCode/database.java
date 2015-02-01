import java.util.*;
import java.io.*;
class database
{
	Set<String> db;
	final File start = new File("data.txt");
	public database()
	{
		db = new HashSet<String>();
		
	}
	public void readDB() throws IOException
	{
		try{
			Scanner read= new Scanner(start);
		while(read.hasNext())
		{
			db.add(read.nextLine());
		}
		}catch(Exception e){
			
		}
		
	}
	public void writeDB() throws IOException
	{
		PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(start.getName())));
		for(String s: db)
			out.println(s);
		out.close();
	}
	public  byte[] getDB(String s) throws IOException
	{
		int min = Integer.MAX_VALUE;
		String best = null;
		File temp1 = new File("");
		for(String ss: db)
		{
			int temp = compare(s,ss);
			if(temp<min)
			{
				min = temp;
				best = ss;
			}
		}
		File bestFile = new File(temp1.getAbsolutePath() + "\\Files\\" + best+".txt");
		FileInputStream readBestFile = new FileInputStream(bestFile);
		ByteArrayOutputStream buffer = new ByteArrayOutputStream();
		int nRead;
		byte[] data = new byte[16384];
		while((nRead = readBestFile.read(data, 0, data.length)) != -1) 
		{
		  buffer.write(data, 0, nRead);
		}
		
		buffer.flush();
		
		return buffer.toByteArray();
		
	}
	public static int compare(String word1, String word2)
	{
		int len1 = word1.length();
		int len2 = word2.length();
	 
		// len1+1, len2+1, because finally return dp[len1][len2]
		int[][] dp = new int[len1 + 1][len2 + 1];
	 
		for (int i = 0; i <= len1; i++) {
			dp[i][0] = i;
		}
	 
		for (int j = 0; j <= len2; j++) {
			dp[0][j] = j;
		}
	 
		//iterate though, and check last char
		for (int i = 0; i < len1; i++) {
			char c1 = word1.charAt(i);
			for (int j = 0; j < len2; j++) {
				char c2 = word2.charAt(j);
	 
				//if last two chars equal
				if (c1 == c2) {
					//update dp value for +1 length
					dp[i + 1][j + 1] = dp[i][j];
				} else {
					int replace = dp[i][j] + 1;
					int insert = dp[i][j + 1] + 1;
					int delete = dp[i + 1][j] + 1;
	 
					int min = replace > insert ? insert : replace;
					min = delete > min ? min : delete;
					dp[i + 1][j + 1] = min;
				}
			}
		}
	 
		return dp[len1][len2];
	}
	public void putDB(String s, byte [] a) throws IOException
	{
		File temp1 = new File("");
		FileOutputStream writeFile = new FileOutputStream(new File(temp1.getAbsolutePath()+"\\Files\\" +s +".txt"),false);
		writeFile.write(a);
		db.add(s);
		writeDB();
	}
}