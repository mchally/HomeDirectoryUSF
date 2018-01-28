import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletHandler;

public class jetty_test {
	protected static Server server;
	public static void main(String[] args) {
		Server server = new Server(2020);
        	ServletHandler handler = new ServletHandler();
		System.out.println("no errors");
	}
}
