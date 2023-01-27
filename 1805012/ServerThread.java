import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.Date;
public class ServerThread extends Thread{
    final int bufferSize =16*1024;
    StringBuffer log;
    Socket socket;
    DataInputStream ind;
    BufferedReader in;
    DataOutputStream out;

    public ServerThread(Socket s){
        this.socket=s;
        log=new StringBuffer();
    }
    private void writeLog() throws Exception{
        File file=new File("log.txt");
        BufferedWriter fos=new BufferedWriter(new FileWriter("log.txt",true));
//        FileOutputStream fos=new FileOutputStream(file);
        fos.write(log.toString());
        fos.flush();
        fos.close();
    }
    private void HTTPResponse(int status, String statusText, String mimeType, byte[] content ) throws IOException {
        String logMessage;
        log.append("HTTP Response: \r\n");
        out.writeBytes(logMessage = "HTTP/1.1 "+status+" "+statusText+"\r\n" +
                    "Server: Java HTTP Server\r\n" +
                    "Date: "+new Date()+"\r\n" +
                    "Content-Type: "+mimeType+" \r\n" +
                    "Content-Length: " + content.length+"\r\n");
        log.append(logMessage);
        out.writeBytes(logMessage="\r\n");
        log.append(logMessage);
        out.write(content,0,content.length) ;
        log.append(new String(content)+"\r\n");
        out.flush();
        log.append("\r\n");
    }
    private void HTTPupload(int status,String statusText, String mimeType, File file) throws IOException {
        FileInputStream fis=new FileInputStream(file);
        byte[] buffer=new byte[bufferSize];
        int count;

        String logMessage;
        log.append("HTTP Response: \r\n");
        out.writeBytes(logMessage="HTTP/1.1 "+status+" "+statusText+"\r\n" +
                "Server: Java HTTP Server\r\n" +
                "Date: "+new Date()+"\r\n" +
                "Content-Type: "+mimeType+"\r\n");
        log.append(logMessage);
        out.writeBytes(logMessage="Transfer-Encoding: chunked\r\n");
        log.append(logMessage);
        out.writeBytes(logMessage="Connection: Keep-Alive\r\n");
        log.append(logMessage);
        out.writeBytes(logMessage="\r\n");
        log.append(logMessage) ;

        while((count=fis.read(buffer)) > 0){
            out.writeBytes(logMessage=(Integer.toHexString(count)+"\r\n"));
            log.append(logMessage);
            out.write(buffer, 0, count);
            log.append(new String(buffer));
            out.writeBytes(logMessage="\r\n");
            log.append(logMessage);
//            out.flush();
        }
        out.writeBytes(logMessage="0\r\n");
        log.append(logMessage);
        out.writeBytes(logMessage="\r\n");
        log.append(logMessage);
        out.flush();
        log.append("\r\n");

        fis.close();
    }
    private void receive_file(String filename) throws IOException{
        File file=new File(filename);
        file.createNewFile();
        FileOutputStream fos=new FileOutputStream(file);
        byte[] buffer=new byte[bufferSize];
        int count;
        while((count=ind.read(buffer))>0){
            fos.write(buffer,0,count);
        }

        fos.close();

    }
    public void run(){
        try{
            ind =new DataInputStream(socket.getInputStream());
            in=new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out=new DataOutputStream(socket.getOutputStream()) ;

            System.out.println(socket.toString());
            log.append(socket.toString()+"\r\n");
            log.append("HTTP Request: \r\n");
            String line=in.readLine();
            System.out.println(line);
            log.append(line+"\r\n\r\n");

            String input[] = line.split(" ");
            String rootPath = System.getProperty("user.dir");

            if( line != null && line.startsWith("GET") ){
                StringBuffer content=new StringBuffer();
                content.append("<div><h1>Hi, I am a Simple Java Server</h1></div>");
                String relPath=input[1].substring(1);
                if( !relPath.isEmpty() ){
                    relPath = "/"+relPath;
                }
                File path=new File(rootPath+input[1]);

                if( !path.exists() ){
                    content.append("<h2>404: Page Not found!!</h2>");
                    System.out.println("404: Page Not found\n");
                    HTTPResponse(404,"NOT FOUND","text/html", String.valueOf(content).getBytes() );
                }
                else if(path.isDirectory()){
                    File fileList[]=path.listFiles();
                    for(File f:fileList){
                        if( f.isDirectory() ){
                            content.append("<a href=\""+relPath+"/"+f.getName()+"\"> <b><i>"+f.getName()+"</i></b></a><br>\n");
                        }
                        else {
                            String temp=Files.probeContentType(f.toPath());
                            if( temp!=null && (temp.startsWith("text") || temp.startsWith("image")) )
                                temp=" target=\"_blank\" ";
                            else temp="";

                            content.append("<a href=\""+relPath+"/"+f.getName()+"\" "+temp+">"+f.getName()+"</a><br>\n");
                        }
                    }
                    HTTPResponse(200,"OK","text/html",String.valueOf(content).getBytes());
                }
                else if(path.isFile()) {
                    String mimeType=Files.probeContentType(path.toPath());
                    System.out.println(mimeType);

                    if( mimeType == null || mimeType.isEmpty() ){
                        HTTPupload(200,"OK","application/octet-stream",path);
                    }
                    else if( mimeType.startsWith("text")){
                        FileInputStream fis=new FileInputStream(path);
                        byte[] b = new byte[(int)path.length()];
                        fis.read(b);
                        String s = new String(b);
                        fis.close();
                        HTTPResponse(200,"OK","text/plain",b);
                    }
                    else if( mimeType.startsWith("image") ){
                        FileInputStream fis=new FileInputStream(path);
                        byte[] b=new byte[(int)path.length()];
                        fis.read(b);
                        String s=new String(b);
                        fis.close();
                        HTTPResponse(200,"OK",mimeType,b);
                    }
                    else {
                        HTTPupload(200,"OK","application/octet-stream",path);
                    }
                }
            }
            else if( line != null && line.startsWith("UPLOAD")){
                String filename=input[1];
                filename=rootPath+"\\uploaded\\"+filename;
                System.out.println("File upload request");
                System.out.println("Filename: "+filename);
                receive_file(filename);
            }

            in.close();
            out.close();
            socket.close();

            writeLog();

        } catch (Exception e ){
            e.printStackTrace();
        }
    }
}
