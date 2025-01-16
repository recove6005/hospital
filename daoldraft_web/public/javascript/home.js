const apiClient = axios.create({
    baseURL: "https://18.226.104.38:80",
    withCredentials: true,
    headers: { "Content-Type":"application/json" },
});

// 로그인 체크
async function checkLogin() {
    // const response = await fetch('/login/current-user', {
    //     method: 'POST',
    //     credentials: "include",
    // });

    // if(!response.ok) {
    //     document.getElementById("to-signin").style.display = 'block';
    // }

    const response = await apiClient.post("/login/current-user");
    if(!response.data) {
        document.getElementById("to-signin").style.display = 'block';
    }
}
checkLogin();

async function checkUserVerify() {
    // const response = await fetch('/login/verify', {
    //     method: 'POST',
    //     credentials: "include",
    // });

    // const result = await response.json();

    // if(response.ok) {
    //     if(result.msg.includes("verify0")) {
    //         window.location.reload();
    //         alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
    //         document.getElementById("to-signin").style.display = 'block';
    //     } 
    //     else {
    //         document.getElementById("profile-photo").style.visibility = 'visible';
    //         document.getElementById("profile-photo").style.display = 'flex';
    //         document.getElementById("profile-photo").style.flexDirection = 'raw';
    //         document.getElementById("profile-photo").style.alignItems = 'center';

    //         document.getElementById("user-email").innerText = result.msg;
            
    //         document.getElementById("to-signin").style.display = 'none';
    //     }
    // }

    try {
        const response = await apiClient.post("/login/verify");
        const result = response.data;
    
        if(result.msg.includes("verify0")) {
            alert("인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.");
                window.location.reload();
                document.getElementById("to-signin").style.display = "block";
        } else {
            document.getElementById("profile-photo").style.visibility = "visible";
                document.getElementById("profile-photo").style.display = "flex";
                document.getElementById("profile-photo").style.flexDirection = "raw";
                document.getElementById("profile-photo").style.alignItems = "center";
    
                document.getElementById("user-email").innerText = result.msg;
    
                document.getElementById("to-signin").style.display = "none";
        }
    } catch(e) {
        console.error("Error verifying user:", e);
    }
    
}
checkUserVerify();

// 드롭다운 관리자 계정 전용 링크 설정
async function checkUserAdminAndDisplay() {
    // const response = await fetch('/login/check-admin', {
    //     method: 'POST',
    //     credentials: "include",  
    // });

    // const result = await response.json();

    // if(response.ok) {
    //     if(result.admin) document.getElementById('dropdown-management').style.display = 'block';  
    //     else document.getElementById('dropdown-management').style.display = 'none';  
    // } else {
    //     console.log(`error: ${result.error}`);
    // }

    const response = await apiClient.post("/login/check-admin");
    const result = response.data;

    if(response.status === 200) {
        if(result.admin) document.getElementById('dropdown-management').style.display = 'block';
        else document.getElementById('dropdown-management').style.display = 'none';    
    } else {
        console.log(`error: ${result.error}`);
    }
}
checkUserAdminAndDisplay();

// Profile link 클릭 시 드롭다운 토글
document.getElementById('profile-link').addEventListener('click', function (e) {
    e.preventDefault(); // 기본 앵커 동작 방지
    const dropdownMenu = document.getElementById('dropdown-menu');
    
    // 드롭다운 메뉴 보이기/숨기기
    if (dropdownMenu.style.display === 'none' || dropdownMenu.style.display === '') {
        dropdownMenu.style.display = 'block';
    } else {
        dropdownMenu.style.display = 'none';
    }
});

// 다른 영역 클릭 시 드롭다운 닫기
document.addEventListener('click', function (e) {
    const dropdownMenu = document.getElementById('dropdown-menu');
    const profilePhoto = document.getElementById('profile-photo');

    if (!profilePhoto.contains(e.target)) {
        dropdownMenu.style.display = 'none';
    }
});

document.getElementById("to-signin").addEventListener('click', () => {
    window.location.href = "/html/login-email.html";
});

// 드롭다운 메뉴 로그아웃
document.getElementById("dropdown-logout").addEventListener('click', async (e) => {
    try {
        // const response = await fetch('/login/logout', {
        //     method: 'POST',
        //     credentials: 'include',
        // });

        // if(!response.ok) {
        //     const error = await response.json();
        //     console.error("Logout failed:", error.msg || "Unknown error");
        //     alert(`Error: ${error.msg || "Logout failed."}`);
        //     return;
        // }

        // const result = await response.json();
        // console.log(result.msg);

    
        const response = await apiClient.post("/login/logout");
        if(response.status === 200) {
            const result = response.data;
            console.log(result.msg);
        
            // 드롭다운 메뉴 숨기기
            const dropdownMenu = document.getElementById('dropdown-menu');
            dropdownMenu.style.display = 'none';

            // 프로필 구역 UI변경
            document.getElementById("profile-photo").style.visibility = 'hidden';
            document.getElementById("profile-photo").style.display = 'none';

            document.getElementById("to-signin").style.visibility = 'visible';
            document.getElementById("to-signin").style.display = 'block';

            window.location.href="../html/home.html";
        } else {
            alert("Logout failed. Please try again.");
        }
    } catch(e) {
    console.error("Unexpected error during logout:", error);
    alert("An unexpected error occurred. Please try again.");
    }
});