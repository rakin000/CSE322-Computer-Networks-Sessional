import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
public class Server {
    private static final int PORT = 5012;


    public static void main(String args[]) throws IOException {
        ServerSocket serverSocket=new ServerSocket(PORT);
        System.out.println("Server started... \nListening on port: "+PORT+"\n");


        while(true){
            Socket socket = serverSocket.accept();
            Thread service=new ServerThread(socket) ;
            service.start();
        }
    }
}
