async function checkUserVerify() {
    const response = await fetch('/login/verify', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        console.log(`${result.msg}`);
        if(result.msg.includes("verify0")) {
            alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
        }
    }
}
checkUserVerify();

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
    window.location.href = "/html/login-email.html";
});


async function displayUserdata() {
    const emailElement = document.getElementById("current-user");
   
    try {
        const response=  await fetch('/login/current-user', {
            method: 'POST',
            credentials: "include",
        });
    
        if(response.ok) {
            const userData = await response.json();
            emailElement.textContent = `Logged in as ${JSON.stringify(userData, null, 2)}`;
        } else {
            console.error("Failed to fetch current user:", response.statusText);
        }
    } catch(e) {
        console.error("Error fetching user data:", e);
    }
}

await displayUserdata();