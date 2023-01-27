import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Scanner;

public class Client {
    static protected final int bufferSize=16*1024;
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        Scanner scn=new Scanner(System.in);

        while(true){
            String cmd[]=scn.nextLine().split(" ");
            if( cmd.length ==0 ) continue ;

            if( cmd[0].equalsIgnoreCase("UPLOAD") ){
                Socket socket=new Socket("localhost", 5012);
                System.out.println(socket);

                try{
                    FileUploader fu=new FileUploader(socket, cmd[1]);
                    fu.start();
                } catch(Exception e){
                    e.printStackTrace();
                }
            }
            else {
                System.out.println("Invalid Command");
            }
        }
    }
}

class FileUploader extends Thread{
    DataOutputStream out;
    File file;
    Socket socket;
    public FileUploader(Socket socket, String s) throws Exception{
        this.socket=socket;
        this.file=new File(s);
        out=new DataOutputStream(socket.getOutputStream());
    }

    public void run() {

        byte[] bytes=new byte[Client.bufferSize];
        int count;
        try{
            String mimeType= Files.probeContentType(file.toPath());

            if( !file.isFile() ){
                System.out.println("Invalid file.");
                out.writeBytes("Invalid file\r\n");
            }
            else if( mimeType==null || !(mimeType.startsWith("image")||mimeType.startsWith("text")) ){
                System.out.println("Invalid format.");
                out.writeBytes("Invalid format\r\n");
            }
            else {
                out.writeBytes("UPLOAD "+file.toPath().getFileName()+"\r\n");
//                System.out.println("Written command");
                FileInputStream fis=new FileInputStream(file);

                while((count=fis.read(bytes))>0){
                    out.write(bytes,0,count);
                }
                fis.close();
            }
            out.close();
            socket.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

    }
}