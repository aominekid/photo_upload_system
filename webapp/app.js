const MINIO_URL = "http://YOUR_EC2_PUBLIC_IP:9000"; // Ersetze mit deiner EC2-IP
const BUCKET_NAME = "wedding-photos";

async function uploadFile() {
    const fileInput = document.getElementById("fileInput");
    const file = fileInput.files[0];

    if (!file) {
        alert("Please select a file to upload.");
        return;
    }

    try {
        const response = await fetch(`${MINIO_URL}/${BUCKET_NAME}/${file.name}`, {
            method: "PUT",
            body: file,
            headers: {
                "Content-Type": file.type
            }
        });

        if (response.ok) {
            alert("File uploaded successfully!");
            displayGallery();
        } else {
            alert("File upload failed.");
        }
    } catch (error) {
        console.error("Error uploading file:", error);
    }
}

async function displayGallery() {
    const galleryDiv = document.getElementById("gallery");
    galleryDiv.innerHTML = "";

    try {
        const response = await fetch(`${MINIO_URL}/${BUCKET_NAME}/`);
        if (response.ok) {
            const xml = await response.text();
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(xml, "application/xml");
            const contents = xmlDoc.getElementsByTagName("Contents");

            for (let i = 0; i < contents.length; i++) {
                const fileName = contents[i].getElementsByTagName("Key")[0].textContent;
                const fileUrl = `${MINIO_URL}/${BUCKET_NAME}/${fileName}`;

                // Bild anzeigen
                const imgElement = document.createElement("img");
                imgElement.src = fileUrl;
                imgElement.alt = fileName;
                imgElement.style = "width: 200px; margin: 10px; display: block;";

                // Download-Link mit Blob erstellen
                const downloadButton = document.createElement("button");
                downloadButton.textContent = "Download";
                downloadButton.style = "display: block; margin-bottom: 20px;";
                downloadButton.onclick = () => downloadFile(fileUrl, fileName);

                // Elemente in die Galerie einfügen
                galleryDiv.appendChild(imgElement);
                galleryDiv.appendChild(downloadButton);
            }
        } else {
            console.error("Failed to load gallery.");
        }
    } catch (error) {
        console.error("Error fetching gallery:", error);
    }
}

async function downloadFile(fileUrl, fileName) {
    try {
        const response = await fetch(fileUrl);
        if (!response.ok) {
            throw new Error("Failed to fetch file.");
        }

        const blob = await response.blob(); // Hole die Datei als Blob
        const url = URL.createObjectURL(blob); // Erstelle eine temporäre URL
        const link = document.createElement("a");
        link.href = url;
        link.download = fileName; // Setze den Dateinamen für den Download
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url); // Bereinige die temporäre URL
    } catch (error) {
        console.error("Error downloading file:", error);
    }
}

// Beim Laden der Seite die Galerie anzeigen
displayGallery();
