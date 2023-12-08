import java.sql.*;
import java.util.Scanner;
import BCrypt.BCrypt;

public class Etudiant {

    private static Connection conn = null;

    public static void main(String[] args) {
        start();
    }

    private static void start(){
        connection();

        int studentId = -1;

        System.out.println("App étudiante");

        Scanner scanner = new Scanner(System.in);

        while (true) {
            System.out.println("Entrer l'adresse e-mail:");
            String mail = scanner.nextLine();
            System.out.println("Entrer le mot de passe:");
            String pw = scanner.nextLine();
            try (PreparedStatement ps = conn.prepareStatement("SELECT et_id, et_mdp FROM projet.etudiants WHERE et_email = ?;")) {
                ps.setString(1, mail);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        boolean connected = BCrypt.checkpw(pw, rs.getString("et_mdp"));
                        if (connected) {
                            studentId = rs.getInt("et_id");
                            break;
                        } else {
                            System.out.println("Mot de passe incorrect. Veuillez réessayer.");
                        }
                    } else {
                        System.out.println("Adresse e-mail non trouvée. Veuillez réessayer.");
                    }
                }
            } catch (SQLException se) {
                se.printStackTrace();
                System.exit(1);
            }
        }

        System.out.println("...\n");
        while (true) {
            System.out.println("Menu:");
            System.out.println("1. Voir offres validees");
            System.out.println("2. Recherche d’une offre de stage par mot clé");
            System.out.println("3. Poser candidature");
            System.out.println("4. Voir candidatures");
            System.out.println("5. Annuler candidature");
            System.out.println("0. Exit \n");
            System.out.print("Entre ton choix: ");
            int choice = scanner.nextInt();
            switch (choice) {

                case 0:
                    System.out.println("exit");
                    return;

                case 1:
                    System.out.println("\n Voir offres validees \n");
                    voir_offres_validees(studentId);
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;

                case 2:
                    System.out.println("Recherche d’une offre de stage par mot clé \n");
                    System.out.print("mot clé: ");
                    scanner.nextLine();
                    String mot = scanner.nextLine();
                    recherche_offres_par_mot_cle(studentId, mot);
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;

                case 3:
                    System.out.println("Poser candidature \n");
                    System.out.print("Code candidature: ");
                    scanner.nextLine();
                    String code = scanner.nextLine();
                    System.out.print("Motivation: ");
                    String motivation = scanner.nextLine();
                    poser_candidature(studentId, code, motivation);
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;

                case 4:
                    System.out.println("Voir candidatures \n");
                    voir_candidatures(studentId);
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;

                case 5:
                    System.out.println("Annuler candidature \n");
                    System.out.println("Code candidature: ");
                    scanner.nextLine();
                    code = scanner.nextLine();
                    annuler_candidature(studentId, code);
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;

                default:
                    System.out.println("Invalid choice \n");
                    System.out.println("continue...");
                    scanner.nextLine();
                    scanner.nextLine();
                    System.out.println();
                    break;
            }
        }
    }

    private static void connection(){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant !");
            System.exit(1);
        }

        String url="jdbc:postgresql://localhost:5432/postgres"; // TODO insert url db
        try {
            conn= DriverManager.getConnection(url,"postgres","postgres"); // TODO insert user and pw
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
    }

    private static void voir_offres_validees(int id){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.voir_offres_validees(?);");
            ps.setInt(1, id);
            try(ResultSet rs= ps.executeQuery()){
                while (rs.next()) {
                    System.out.println("of_code: " + rs.getString("of_code"));
                    System.out.println("en_nom: " + rs.getString("en_nom"));
                    System.out.println("en_adresse: " + rs.getString("en_adresse"));
                    System.out.println("of_description: " + rs.getString("of_description"));
                    System.out.println("mots_cles: " + rs.getString("mots_cles\n"));
                }
            }
            catch (Exception e){
                System.out.println(e);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }
    }

    private static void recherche_offres_par_mot_cle(int id, String mot){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.recherche_offres_par_mot_cle(?, ?);");
            ps.setInt(1, id);
            ps.setString(2, mot);
            try(ResultSet rs= ps.executeQuery()){
                while(rs.next()) {
                    System.out.println("of_code: " + rs.getString("of_code"));
                    System.out.println("en_nom: " + rs.getString("en_nom"));
                    System.out.println("en_adresse: " + rs.getString("en_adresse"));
                    System.out.println("of_description: " + rs.getString("of_description"));
                    System.out.println("mots_cles: " + rs.getString("mots_cles\n"));
                }
            }
            catch (Exception e){
                System.out.println(e);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }
    }

    private static void poser_candidature(int id, String code_offre, String motivation){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT projet.poser_candidature(?, ?, ?);");
            ps.setInt(1, id);
            ps.setString(2, code_offre);
            ps.setString(3, motivation);
            try(ResultSet rs= ps.executeQuery()){
                while(rs.next()) {
                    System.out.println(rs.getString(1));
                }
            }
            catch (Exception e){
                System.out.println(e);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }
    }

    private static void voir_candidatures(int id){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM projet.voir_candidatures(?);");
            ps.setInt(1, id);
            try(ResultSet rs= ps.executeQuery()){
                while (rs.next()) {
                    System.out.println("of_code: " + rs.getString("of_code"));
                    System.out.println("en_nom: " + rs.getString("en_nom"));
                    System.out.println("ca_etat: " + rs.getString("ca_etat\n"));
                }
            }
            catch (Exception e){
                System.out.println(e);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }
    }

    private static void annuler_candidature(int id, String code_offre){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT projet.annuler_candidature(?, ?);");
            ps.setInt(1, id);
            ps.setString(2, code_offre);
            try(ResultSet rs= ps.executeQuery()){
                System.out.println("Candidature annulée avec succès.");
            }
            catch (Exception e){
                System.out.println(e);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            System.exit(1);
        }
    }
}