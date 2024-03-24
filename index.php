<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fridge Management System</title>
    <link rel="stylesheet" href="style.css?v=1.2">
</head>
<body>
    <h1 align="center">Refrigeration Management System</h1>
    <marquee><h4><i>A new way to manage your refrigerator items... :D</i></h4></marquee>

    <section class="add-item-card">
        <h2 align="center">Add New Item</h2>
        <form method="post" action="" align="center">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" required><br><br>
            <label for="category">Category:</label>
            <select id="category" name="category" required>
                <option value="diary">Diary</option>
                <option value="vegetable">Vegetable</option>
                <option value="meat">Meat</option>
            </select><br><br>
            <label for="quantity">Quantity:</label>
            <input type="number" id="quantity" name="quantity" required><br><br>
            <label for="expiry_date">Expiry Date:</label>
            <input type="date" id="expiry_date" name="expiry_date" required><br><br>
            <input type="submit" value="Add Item">
        </form>
    </section>

    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $mysqli = new mysqli("localhost", "root", "", "fridge_management");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }
        $name = $_POST['name'];
        $category = $_POST['category'];
        $quantity = $_POST['quantity'];
        $expiry_date = $_POST['expiry_date'];

        $sql = "INSERT INTO items (name, category, quantity, expiry_date) VALUES (?, ?, ?, ?)";
        $stmt = $mysqli->prepare($sql);
        if ($stmt) {
            $stmt->bind_param("ssis", $name, $category, $quantity, $expiry_date);
            if ($stmt->execute()) {
                echo "<p>New item added successfully.</p>";

                $lastItemId = $mysqli->insert_id;
                
                switch ($category) {
                    case 'diary':
                        $categoryTable = 'diary_products';
                        break;
                    case 'vegetable':
                        $categoryTable = 'vegetables';
                        break;
                    case 'meat':
                        $categoryTable = 'meat_products';
                        break;
                    default:
                        $categoryTable = '';
                        break;
                }

                if (!empty($categoryTable)) {
                    $sqlCategory = "INSERT INTO $categoryTable (item_id) VALUES (?)";
                    $stmtCategory = $mysqli->prepare($sqlCategory);
                    if ($stmtCategory) {
                        $stmtCategory->bind_param("i", $lastItemId);
                        if (!$stmtCategory->execute()) {
                            echo "Error in category-specific insertion: " . $stmtCategory->error;
                        }
                        $stmtCategory->close();
                    } else {
                        echo "Error preparing category-specific statement: " . $mysqli->error;
                    }
                }
            } else {
                echo "Error: " . $stmt->error;
            }
            
            $stmt->close();
        } else {
            echo "Error preparing statement: " . $mysqli->error;
        }
        $mysqli->close();
    }
    ?>

    <h2>Items expiring in less than 7 days:</h2>
    <table id="expiring-items-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Quantity</th>
                <th>Expiry Date</th>
            </tr>
        </thead>
        <tbody>
            <?php
            $mysqli = new mysqli("localhost", "root", "", "fridge_management");

            if ($mysqli->connect_error) {
                die("Connection failed: " . $mysqli->connect_error);
            }

            function getExpiringItems($mysqli) {
                $sql = "SELECT * FROM items WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)";
                $result = $mysqli->query($sql);
                return $result->fetch_all(MYSQLI_ASSOC);
            }

            $expiringItems = getExpiringItems($mysqli);

            foreach ($expiringItems as $item) {
                echo "<tr>";
                echo "<td>{$item['name']}</td>";
                echo "<td>{$item['category']}</td>";
                echo "<td>{$item['quantity']}</td>";
                echo "<td>{$item['expiry_date']}</td>";
                echo "</tr>";
            }

            $mysqli->close();
            ?>
        </tbody>
    </table>

<h2>All Items</h2>
<?php
$mysqli = new mysqli("localhost", "root", "", "fridge_management");

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

function fetchItemsByCategory($mysqli, $categoryTable, $categoryName) {

    $sql = "SELECT items.id, items.name, items.category, items.quantity, items.expiry_date 
            FROM items 
            JOIN $categoryTable ON items.id = $categoryTable.item_id 
            WHERE items.category = ? 
            ORDER BY items.name";

    $stmt = $mysqli->prepare($sql);

    if (!$stmt) {
        echo "Error preparing statement: " . $mysqli->error;
        return;
    }

    $stmt->bind_param("s", $categoryName);
    if (!$stmt->execute()) {
        echo "Error executing statement: " . $stmt->error;
        return;
    }

    $result = $stmt->get_result();
    if ($result->num_rows > 0) {
        echo "<h3>" . ucfirst($categoryName) . "</h3>";
        echo "<table>";
        echo "<thead><tr><th>Name</th><th>Category</th><th>Quantity</th><th>Expiry Date</th></tr></thead>";
        echo "<tbody>";
        while ($row = $result->fetch_assoc()) {
            echo "<tr><td>{$row['name']}</td><td>{$row['category']}</td><td>{$row['quantity']}</td><td>{$row['expiry_date']}</td></tr>";
        }
        echo "</tbody>";
        echo "</table><br>";
    } else {
        echo "<p>No items found in " . ucfirst($categoryName) . " category.</p>";
    }

    $stmt->close();
}

fetchItemsByCategory($mysqli, "diary_products", "diary");
fetchItemsByCategory($mysqli, "vegetables", "vegetable");
fetchItemsByCategory($mysqli, "meat_products", "meat");

$mysqli->close();
?>

</body>
</html>