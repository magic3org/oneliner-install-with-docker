<?php
// #######################################################################
// テスト用サンプル
// ・デフォルトのエンコーディング(UTF-8)の確認
// ・日本語データの登録、取得
// #######################################################################

$host = '127.0.0.1';
$db   = getenv('MYSQL_DATABASE') ?: 'test';
$user = getenv('MYSQL_USER') ?: 'root';
$pass = getenv('MYSQL_PASSWORD') ?: '1234567890';

$dsn = "mysql:host=$host;dbname=$db";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION
];
try {
    $pdo = new PDO($dsn, $user, $pass, $options);

    // SQL作成
    $sql = 'CREATE TABLE IF NOT EXISTS user (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(20)
    )';

    // SQL実行
    $res = $pdo->query($sql);
} catch (PDOException $e) {
     throw new PDOException($e->getMessage(), (int)$e->getCode());
}
echo 'DB connected...<br />';

try {
    $pdo->beginTransaction();

    $pdo->exec('DELETE FROM user');

    $stmt = $pdo->prepare("INSERT INTO user (name) VALUES (?)");
    foreach (['太郎','花子','一郎','次郎'] as $name)
    {
        $stmt->execute([$name]);
    }

    $pdo->commit();

    $sql = 'SELECT * FROM user ORDER BY id';
    $stmt = $pdo->query($sql);

    while($result = $stmt->fetch(PDO::FETCH_ASSOC)){
        echo $result['id'];
        echo $result['name'] . '<br>';
    }
} catch (PDOException $e){
    if ($pdo->inTransaction()) $pdo->rollback();
    throw new PDOException($e->getMessage(), (int)$e->getCode());
}
?>
