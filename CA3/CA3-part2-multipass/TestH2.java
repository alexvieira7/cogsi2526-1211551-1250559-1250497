  import java.sql.*;
  public class TestH2 {
    public static void main(String[] args) throws Exception {
      String url = "jdbc:h2:tcp://10.216.117.23:9092/ca3-db";
      Class.forName("org.h2.Driver");
      try (Connection c = DriverManager.getConnection(url, "sa", "")) {
        try (Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT 1")) {
          while (rs.next()) System.out.println("Result: " + rs.getInt(1));
        }
      }
    }
  }
