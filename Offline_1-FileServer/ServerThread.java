import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Date;

public class ServerThread extends Thread{
    Socket socket;
    BufferedReader in;
    PrintWriter out;

    public ServerThread(Socket s){ this.socket=s; }
    private void HTTPResponse(int status, String statusText, String mimeType, String content ){
        out.write("HTTP/1.1 "+status+" "+statusText+"\r\n" +
                    "Server: Java HTTP Server\r\n" +
                    "Date: "+new Date()+"\r\n" +
                    "Content-Type: "+mimeType+" \r\n" +
                    "Content-Length: " + content.length()+"\r\n");
        out.write("\r\n");
        out.write(content) ;
        out.flush();
    }
    public void run(){
        try{
            in =new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out=new PrintWriter(socket.getOutputStream()) ;

            System.out.println(socket.toString());
            String line=in.readLine();
            System.out.println(line);

            if( line != null && line.startsWith("GET") ){
                StringBuffer content=new StringBuffer();
                content.append("<div><h1>Hi, I am a Simple Java Server</h1></div>");
                String input[]=line.split(" ");
                String relPath=input[1].substring(1);
                if( !relPath.isEmpty() ){
                    relPath = "/"+relPath;
                }
                File dir=new File(System.getProperty("user.dir")+input[1]);

                if( !dir.exists() ){
                    content.append("<h2>File Not found!!</h2>");
                    HTTPResponse(404,"NOT FOUND","text/html", content.toString());
                }
                else if(dir.isDirectory()){
                    File fileList[]=dir.listFiles();
                    for(File f:fileList){
                        if( f.isDirectory() ){
                            content.append("<a href="+relPath+"/"+f.getName()+"> <b><i>"+f.getName()+"</i></b></a><br>\n");
                        }
                        else {
                            content.append("<a href="+relPath+"/"+f.getName()+">"+f.getName()+"</a><br>\n");
                        }
                    }
                    HTTPResponse(200,"OK","text/html",content.toString());
                }
                else if(dir.isFile()) {
                    FileInputStream fis=new FileInputStream(dir);
                    byte[] b = new byte[(int)dir.length()];
                    fis.read(b);
                    String s = new String(b);
                    fis.close();
                    HTTPResponse(200,"OK","text/plain",s);
                }
            }
            else if( line != null && line.startsWith("UPLOAD")){

            }

            socket.close();
        } catch (Exception e ){
            e.printStackTrace();
        }
    }
}
