async function fetchdata() {
    const response = await fetch('/read');
    const data = await response.json();

    const list = document.getElementById('data-list');
    list.innerHTML = '';
    data.forEach(item => {
        const li = document.createElement('li');
        li.textContent = item.name;
        list.appendChild(li);
    });
}

fetchdata();

document.getElementById('add-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('name').value;

    await fetch('/add', {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({name}),
    });

    fetchdata();
});


document.getElementById("to-signin").addEventListener('click', () => {
    window.location.href = "signin-email.html";
});