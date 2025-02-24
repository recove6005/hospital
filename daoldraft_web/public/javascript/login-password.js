document.getElementById("login-button").addEventListener("click", async (e) => {
    e.preventDefault();

    const loadingScreen = document.getElementById("loading-screen");
    loadingScreen.style.display = "flex"; // 로딩 화면 표시
    
    const param = new URLSearchParams(window.location.search);
    const email = param.get('email');
    document.getElementById('email').value = email;

    const password = document.getElementById('password').value;
    const consent = document.getElementById('consent-input').checked;

    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*[\W])(?=.{8,}).*$/;

    if(consent) {
        if(passwordRegex.test(password)) {
            try {
                const loginResponse = await fetch('/login/login', {
                    method: 'POST',
                    headers: {'Content-Type':'application/json'},
                    body: JSON.stringify({ email, password }),
                });

                const loginResult = await loginResponse.json();
                
                if(loginResult.code === '0') {
                    // 사용자가 없음 >> 회원가입 절차
                    const response = await fetch('/login/register', {
                        method: 'POST',
                        headers: { 'Content-Type' : 'application/json'},
                        body: JSON.stringify({ email, password }),
                    });
                            
                    if(response.ok) {
                        alert(`어서오세요, ${email}님`);
                        window.location.href = "/page/home.html";
                    } else {
                        alert(`error`);
                    }
                    return;
                }
                else if(loginResult.code === '1') {
                    alert(`비밀번호가 옳지 않습니다. ${loginResult.code}`);
                    return;
                }
                
                if(loginResponse.status === 200) {
                    alert(`어서오세요, ${loginResult.email}`);
                    window.location.href = "../page/home.html";
                } 
                else {
                    alert(`이메일과 비밀번호를 확인해주세요.`);
                }

            } catch(e) {
                console.error("Error:", e);
                alert("An error occurred: " + e.message);
            } finally {
                loadingScreen.style.display = "none"; // 로딩 화면 숨김
            };
        } else {
            alert('비밀번호는 특수문자와 영문자를 포함하는 8자리 이상의 문자여야 합니다.');
            loadingScreen.style.display = "none"; // 로딩 화면 숨김
        }
    } else {
        alert('개인정보처리방침 및 이용약관에 동의해 주세요.');
        loadingScreen.style.display = "none"; // 로딩 화면 숨김
    }
});