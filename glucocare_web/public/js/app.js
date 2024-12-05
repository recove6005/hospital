document.getElementById("fetchData").addEventListener("click", async () => {
    console.log('button is clicked.');
    const response = await fetch('/api/data');
    const data = await response.json();
    document.getElementById("output").innerText = JSON.stringify(data);
});