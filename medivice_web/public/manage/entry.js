document.getElementById('entry-btn').addEventListener('click', async () =>{
    const key = document.getElementById('entry-key').value;
    const keyCheckResponse = await fetch('/api/entry/store-validate', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ key: key }),
    });    

    if (keyCheckResponse.redirected) {
        window.location.href = keyCheckResponse.url;
    } else {
        alert('error');
    }
});