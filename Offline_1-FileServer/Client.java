import java.io.*;
import java.net.Socket;
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
    PrintWriter outp;
    File file;
    Socket socket;
    public FileUploader(Socket socket, String s) throws Exception{
        this.socket=socket;
        this.file=new File(s);
        out=new DataOutputStream(socket.getOutputStream());
        outp=new PrintWriter(socket.getOutputStream());
    }

    public void run() {

        byte[] bytes=new byte[Client.bufferSize];
        int count;
        try{
            outp.write("UPLOAD file1\r\n");
            FileInputStream fis=new FileInputStream(file);

            while((count=fis.read(bytes))>0){
                out.write(bytes,0,count);
            }
            fis.close();
            out.close();
            socket.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

    }
}