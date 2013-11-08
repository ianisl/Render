import java.util.Calendar;
import java.io.InputStreamReader;

class Render
{
	String renderer;
	String path; // absolute path to the folder where images should be recorded
	String fullRenderPath; // images are sorted in subfolders within "path". This is the current subfolder given git version and date
	String gitVersionHash;
	int runId; // for each day, the runId increases by 1 each time the program is launched and at least one image has been saved
	int renderId = 1; // for each run, the renderId increases by 1 each time an image is saved 
	String today;

	Render(String renderer, String path)
	{
		this.renderer = renderer;
		if (!path.endsWith("/"))
		{
			path += "/";
		}
		this.path = path;
		gitVersionHash = getGitVersionHash();
		today = getTimeStamp();
		fullRenderPath = path + gitVersionHash + "/" + today + "/";
		runId = getRunId();
	}

	String getTimeStamp() 
	{
		Calendar now = Calendar.getInstance();
		return String.format("20%1$ty-%1$tm-%1$td", now);
	}

	void startRendering()
	{
		String suffix = "";
		if (renderer.equals(PDF))
		{
			suffix = ".pdf";
		} else if (renderer.equals(P2D))
		{
			suffix = ".jpg";
		}
		beginRecord(renderer, fullRenderPath + today + "-" + runId + "-" + renderId + suffix);
	}

	void stopRendering()
	{
		endRecord();
		renderId++;
	}

	String getGitVersionHash()
	{
		try 
		{
			ProcessBuilder processBuilder = new ProcessBuilder("/usr/local/bin/git", "rev-parse", "--short", "HEAD");
			processBuilder.directory(new File(sketchPath));
		    processBuilder.redirectErrorStream(true); // Initially, this property is false, meaning that the standard output and error output of a subprocess are sent to two separate streams
			Process p = processBuilder.start();
		    BufferedReader output = new BufferedReader(new InputStreamReader(p.getInputStream()));
		    String hash = output.readLine();
		    p.waitFor();
		    output.close();
		    return hash;
		} catch (Exception e) 
		{
			return null;
		} 
	}

	int getRunId()
	{
    	String[] fileNames = listFileNames(fullRenderPath);
    	if (fileNames != null)
    	{
    		// if some images were previously recorded for this version
    		int runId = 1;
    		for (String n : fileNames)
    		{
    			if (n.startsWith(today))
    			{
    				// if at least one image was previously recorded on this day
    				String[] s = n.split("-");
    				runId = Integer.parseInt(s[3]); // retrieve runId
    				runId++;
    				break;
    			}
    		}
    		return runId;
    	} else
    	{
    		// if no image was previously recorded for this version, start runId at 1
    		return 1;
    	}
	}

	String[] listFileNames(String dir) 
	{
  		File file = new File(dir);
  		if (file.isDirectory()) 
  		{
    		String names[] = file.list();
    		return names;
  		} else 
  		{
		    return null;
  		}
	}

}