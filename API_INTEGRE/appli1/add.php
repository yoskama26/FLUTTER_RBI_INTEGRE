<?php
ob_start();
?>
<?php
$content = ob_get_clean();
require_once("template.php");

$servername = "localhost";
$username = "u133334539_robin";
$password = "C4asino1";
$dbname = "u133334539_bdd_emerald";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $codeMagasin = $_POST["codeMagasin"];
    $matriculeCreation = $_POST["matriculeCreation"];
    $dateVisite = $_POST["dateVisite"];
    $note = $_POST["note"];
    $motifVisite = $_POST["motifVisite"];
    $rapportVisite = $_POST["rapportVisite"];

    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $imageTmpName = $_FILES['image']['tmp_name'];
        $imageFileName = $_FILES['image']['name'];

        $ftpDirectory = '/domains/projetemerald.fr/public_html/fdvpict';

        $ftpFilePath = $ftpDirectory . '/' . $imageFileName;
        
        $ftpServer = '89.116.147.136';
        $ftpUsername = 'u133334539';
        $ftpPassword = '$Imon00700';

        $ftpConnection = ftp_connect($ftpServer);
        ftp_login($ftpConnection, $ftpUsername, $ftpPassword);

        if (ftp_put($ftpConnection, $ftpFilePath, $imageTmpName, FTP_BINARY)) {

            $imageName = $imageFileName;

            $conn = new mysqli($servername, $username, $password, $dbname);
            if ($conn->connect_error) {
                die("Erreur de connexion à la base de données : " . $conn->connect_error);
            }

            $stmt = $conn->prepare("INSERT INTO fiche_visite_autre2 (code_CM, matricule_creation, date_visite, NOTE_1, Motif_visite, Rapport_visite, IMAGE_1) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("sssssss", $codeMagasin, $matriculeCreation, $dateVisite, $note, $motifVisite, $rapportVisite, $imageName);

            if ($stmt->execute()) {
                echo "La fiche a été ajoutée avec succès.";
            } else {
                echo "Erreur lors de l'ajout de la fiche : " . $stmt->error;
            }

            $stmt->close();
            $conn->close();

        } else {
            echo "Erreur lors du téléchargement de l'image sur le serveur FTP.";
        }

        ftp_close($ftpConnection);
    } else {
        echo "Veuillez sélectionner une image.";
    }
}

$themes = [];
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Erreur de connexion à la base de données : " . $conn->connect_error);
}

$sql = "SELECT * FROM themes";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $themes[] = $row["theme"];
    }
}

$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Ajouter une nouvelle fiche</title>
    <style>
        .card {
            width: 600px;
            margin: 0 auto;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        form {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        h1 {
            text-align: left;
        }

        .form-row {
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }

        .form-row label {
            display: inline-block;
            width: 200px;
            text-align: right;
            margin-right: 10px;
        }

        .form-row input,
        .form-row select,
        .form-row textarea {
            width: 300px;
        }
    </style>
</head>
<body>
    <h1>Ajouter une nouvelle fiche</h1>
    <div class="card">
        <form method="post" action="<?php echo $_SERVER["PHP_SELF"]; ?>" enctype="multipart/form-data">
            <div class="form-row">
                <label for="codeMagasin">Code du magasin :</label>
                <input type="text" id="codeMagasin" name="codeMagasin" required>
            </div>

            <div class="form-row">
                <label for="matriculeCreation">Matricule de création :</label>
                <input type="text" id="matriculeCreation" name="matriculeCreation" required>
            </div>

            <div class="form-row">
                <label for="dateVisite">Date de visite :</label>
                <input type="date" id="dateVisite" name="dateVisite" required>
            </div>

            <div class="form-row">
                <label for="note">Note :</label>
                <input type="number" id="note" name="note" required>
            </div>

            <div class="form-row">
                <label for="motifVisite">Motif de visite :</label>
                <select id="motifVisite" name="motifVisite" required>
                    <?php foreach ($themes as $theme) : ?>
                        <option value="<?php echo $theme; ?>"><?php echo $theme; ?></option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-row">
                <label for="rapportVisite">Rapport de visite :</label>
                <textarea id="rapportVisite" name="rapportVisite" rows="5" required></textarea>
            </div>

            <div class="form-row">
                <label for="image">Image :</label>
                <input type="file" id="image" name="image" accept="image/*">
            </div>

            <div class="form-row">
                <input type="submit" value="Ajouter la fiche">
            </div>
        </form>
    </div>
</body> 
</html>
