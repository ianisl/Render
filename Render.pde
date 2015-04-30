import java.util.Calendar;

// Classes named Render* (RenderCustom, RenderBase, Render, ...) define rendering jobs.
// To define custom rendering jobs outside these classes, a Renderer interface must be implemented.

public class Render extends RenderBase
{
    // Basic renderer.
    // Export to jpg or pdf (this will only work
    // if the sketch is using Processing shape primitives).
    boolean isRenderingJpg = false;
    boolean isRenderingPdf = false;
    boolean hasRenderingStarted = false;
    String renderer;

    Render(PApplet applet, String baseFolder)
    {
        super(applet, baseFolder);
        applet.registerPre(this); // register the pre event
        applet.registerDraw(this); // register the draw event
        renderer = applet.g.getClass().getName();
    }

    Render(PApplet applet, String baseFolder, String fileName)
    {
        super(applet, baseFolder, fileName);
        applet.registerPre(this);
        applet.registerDraw(this);
        renderer = applet.g.getClass().getName();
    }

    void pre()
    {
        // The following code will be called just before the main applet's draw method
        if (isRenderingPdf || isRenderingJpg)
        {
            updateFilePath();
            if (isRenderingPdf)
            {
                if (renderer.equals(P2D) || renderer.equals(PDF))
                {
                    beginRecord(PDF, filePathWithoutExtension + ".pdf");
                } else if (renderer.equals(P3D))
                {
                    beginRaw(PDF, filePathWithoutExtension + ".pdf");
                }
            }
            hasRenderingStarted = true;
            save(filePathWithoutExtension + ".jpg");
        }
    }

    void draw()
    {
        // The following code will be called just after the main applet's draw() method
        // since the renderPdf method might be called in the middle of the main applet's draw method, 
        // we need to check if pdf rendering has actually started.
        if (hasRenderingStarted)
        {
            if (isRenderingPdf)
            {
                if (renderer.equals(P2D) || renderer.equals(PDF))
                {
                    endRecord();
                } else if (renderer.equals(P3D))
                {
                    endRaw();
                }
                isRenderingPdf = false;
            }
            if (isRenderingJpg)
            {
                isRenderingJpg = false;
            }
            hasRenderingStarted = false;
            renderId++;
        }
    }

    void renderPdf()
    {
        isRenderingPdf = true;
    }

    void renderPdfAndJpg()
    {
        isRenderingPdf = true;
        isRenderingJpg = true;
    }

    void renderJpg()
    {
        isRenderingJpg = true;
    }

    boolean isRenderingPdf()
    {
        return isRenderingPdf;
    }

    boolean isRenderingJpg()
    {
        return isRenderingJpg;
    }

}

public class RenderBase
{
    // This class contains the basic file system operations needed by renderers.
    String baseFolder; // absolute path to the folder containing the different render folders
    String renderFolder; // absolute path to the render folder in which images will be saved
    int runId; // for each day, the runId increases by 1 each time the program is launched and at least one image has been saved
    int renderId; // for each run, the renderId increases by 1 each time an image is saved 
    String today;
    String filePathWithoutExtension; // Path of the next rendered file
    String fileName; // Custom filename, if provided
    boolean hasRenderingStarted;
    boolean isSortedByDate;
    RenderBase(PApplet applet, String baseFolder)
    {
        if (!baseFolder.endsWith("/"))
        {
            baseFolder += "/";
        }
        renderId = 1;
        hasRenderingStarted = false;
        isSortedByDate = true;
        fileName = "";
        this.baseFolder = baseFolder;
        today = getTimeStamp();
        renderFolder = baseFolder + today + "/";
        runId = getRunId();
        updateFilePath();
    }

    RenderBase(PApplet applet, String baseFolder, String fileName)
    {
        this(applet, baseFolder);
        this.fileName = fileName;
        updateFilePath();
    }

    void sortByDate(boolean b)
    {
        if (b && !isSortedByDate)
        {
            renderFolder += today + "/";
        }
        else if (!b && isSortedByDate)
        {
            renderFolder = renderFolder.substring(0, renderFolder.length() - 12) + "/"; // remove the date
        }
        runId = getRunId();
        updateFilePath();
    }

    void updateFilePath()
    {
        if (!fileName.equals(""))
        {
            filePathWithoutExtension = renderFolder + fileName;
        }
        else
        {
            filePathWithoutExtension = renderFolder + getAutomaticFileName();
        }
    }

    String getAutomaticFileName()
    {
        return today + "-" + runId + "-" + renderId;
    }

    String getTimeStamp()
    {
        Calendar now = Calendar.getInstance();
        return String.format("20%1$ty-%1$tm-%1$td", now);
    }

    int getRunId()
    {
        String[] fileNames = listFileNames(renderFolder);
        if (fileNames != null)
        {
            // if some images were previously recorded for this version
            int runId = 0; // We start at 0: if no previous runId is found, runId will be increased to 1
            for (String n : fileNames)
            {
                if (n.startsWith(today))
                {
                    // if at least one image was previously recorded on this day
                    String[] s = n.split("-");
                    if (s.length > 3)
                    {
                        int id = Integer.parseInt(s[3]);
                        if (id > runId)
                        {
                            runId = id; // we want to retrieve the highest runId
                        } 
                    }
                }
            }
            runId++;
            return runId;
        }
        else
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
        }
        else
        {
            return null;
        }
    }

}