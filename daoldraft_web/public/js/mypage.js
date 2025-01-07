var subscribeType = '';

async function getUserInitData() {
    // 구독권 타입
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        subscribeType = result.subscribe;
    } else {
        console.log(`error : ${result.error}`);
    }
}
getUserInitData();

async function checkUserVerify() {
    const response = await fetch('/login/verify', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        if(result.msg.includes("verify0")) {
            window.location.reload();
            alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
        } 
        else {
            document.getElementById("profile-photo").style.visibility = 'visible';
            document.getElementById("profile-photo").style.display = 'flex';
            document.getElementById("profile-photo").style.flexDirection = 'raw';
            document.getElementById("profile-photo").style.alignItems = 'center';

            document.getElementById("user-email").innerText = result.msg;
            
            document.getElementById("to-signin").style.display = 'none';
        }
    }
}
checkUserVerify();

// 드롭다운 관리자 계정 전용 링크 설정
async function checkUserAdminAndDisplay() {
    const response = await fetch('/login/check-admin', {
        method: 'POST',
        credentials: "include",  
    });

    const result = await response.json();

    if(response.ok) {
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
        const response = await fetch('/login/logout', {
            method: 'POST',
            credentials: 'include',
        });

        if(!response.ok) {
            const error = await response.json();
            console.error("Logout failed:", error.msg || "Unknown error");
            alert(`Error: ${error.msg || "Logout failed."}`);
            return;
        }

        const result = await response.json();

        // 드롭다운 메뉴 숨기기
        const dropdownMenu = document.getElementById('dropdown-menu');
        dropdownMenu.style.display = 'none';

        // 프로필 구역 UI변경
        document.getElementById("profile-photo").style.visibility = 'hidden';
        document.getElementById("profile-photo").style.display = 'none';

        document.getElementById("to-signin").style.visibility = 'visible';
        document.getElementById("to-signin").style.display = 'block';
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});


// Project 데이터 리스트 (예시 데이터)
const userProjects = [];

// 프로젝트 정보 가져오기
async function getProjects() {
    const response = await fetch('/project/get-projects-by-uid', {
        method: 'POST',
    });

    const result = await response.json();
    if(response.ok) {
        result.forEach((pjt) => {
            userProjects.push(pjt);
            console.log(`pjt: ${pjt} ${pjt.title}`);
        });
    } else {
        console.log(`error: ${result.error}`);
    }
}

// main-project-info innerHTML
function getMainProjectInfo(index) {
    const pjt = userProjects[index];
    const projectInfo = document.getElementById('main-project-info');
    projectInfo.innerHTML = `
            <div class="description">
                <p class="description-title">기관명</p>
                <p class="description-content" id="organization">${pjt.organization}</p>
            </div>
            <div class="description">
                <p class="description-title">성함</p>
                <p class="description-content" id="name">${pjt.name}</p>
            </div>
            <div class="description">
                <p class="description-title">직위</p>
                <p class="description-content" id="rank">${pjt.rank}</p>
            </div>
            <div class="description">
                <p class="description-title">연락처</p>
                <p class="description-content" id="phone">${pjt.phone}</p>
            </div>
            <div class="description">
                <p class="description-title">문의내용</p>
                <p class="description-content" id="details">${pjt.details}</p>
            </div>
            <div class="description">
                <p class="description-title">가격</p>
                <p class="description-content" id="allprice">${pjt.allprice}원</p>
            </div>
        `;
}

// progress ui
function getProgressUI(index) {
    if(userProjects[index].progress == '0') {
        document.getElementById('progress-step-0').classList.add('active');

        document.getElementById('progress-step-1').classList.remove('active');
        document.getElementById('progress-line-1').classList.remove('active');
        document.getElementById('progress-step-2').classList.remove('active');
        document.getElementById('progress-line-2').classList.remove('active');
        document.getElementById('progress-step-3').classList.remove('active');
        document.getElementById('progress-line-3').classList.remove('active');

        document.getElementById('request-payment').style.display = 'none';
        document.getElementById('download-file').style.display = 'none';
        document.getElementById('checking-payment').style.display = 'none';
    } 
    else if(userProjects[index].progress == '1') {
        document.getElementById('progress-step-0').classList.add('active');
        document.getElementById('progress-step-1').classList.add('active');
        document.getElementById('progress-line-1').classList.add('active');

        document.getElementById('progress-step-2').classList.remove('active');
        document.getElementById('progress-line-2').classList.remove('active');
        document.getElementById('progress-step-3').classList.remove('active');
        document.getElementById('progress-line-3').classList.remove('active');

        document.getElementById('request-payment').style.display = 'none';
        document.getElementById('download-file').style.display = 'none';
        document.getElementById('checking-payment').style.display = 'none';
    }
    else if(userProjects[index].progress == '2') {
        document.getElementById('progress-step-0').classList.add('active');
        document.getElementById('progress-step-1').classList.add('active');
        document.getElementById('progress-line-1').classList.add('active');
        document.getElementById('progress-step-2').classList.add('active');
        document.getElementById('progress-line-2').classList.add('active');

        document.getElementById('progress-step-3').classList.remove('active');
        document.getElementById('progress-line-3').classList.remove('active');

        document.getElementById('request-payment').style.display = 'flex';
        document.getElementById('download-file').style.display = 'none';
        document.getElementById('checking-payment').style.display = 'none';
    }
    else if(userProjects[index].progress == '3') {
        document.getElementById('progress-step-0').classList.add('active');
        document.getElementById('progress-step-1').classList.add('active');
        document.getElementById('progress-line-1').classList.add('active');
        document.getElementById('progress-step-2').classList.add('active');
        document.getElementById('progress-line-2').classList.add('active');
        document.getElementById('progress-step-3').classList.add('active');
        document.getElementById('progress-line-3').classList.add('active');

        document.getElementById('request-payment').style.display = 'none';
        document.getElementById('download-file').style.display = 'flex';
        document.getElementById('checking-payment').style.display = 'none';
    }
    else if(userProjects[index].progress == '11') {
        document.getElementById('progress-step-0').classList.add('active');
        document.getElementById('progress-step-1').classList.add('active');
        document.getElementById('progress-line-1').classList.add('active');
        document.getElementById('progress-step-2').classList.add('active');
        document.getElementById('progress-line-2').classList.add('active');

        document.getElementById('progress-step-3').classList.remove('active');
        document.getElementById('progress-line-3').classList.remove('active');
        
        document.getElementById('request-payment').style.display = 'none';
        document.getElementById('download-file').style.display = 'none';
        document.getElementById('checking-payment').style.display = 'flex';
    }
}

// 초기 UI 업데이트 함수
async function initProjectInfo() {
    // 스와이퍼
    await getProjects();
    const wrapper = document.getElementById('swipe-wrapper');
    userProjects.forEach((pjt) => {
        const div = document.createElement('div');
        div.classList.add('item');
        
        if(pjt.size == "") div.innerHTML = `<p class="project-name">${pjt.title}</p>`;
        else div.innerHTML = `<p class="project-name">${pjt.title} (${pjt.size})</p>`;
        wrapper.appendChild(div);
    });

    // main project info
    getMainProjectInfo(0);

    // progress
    getProgressUI(0);
}
initProjectInfo();

// 스와이프 셀렉터
const swipeWrapper = document.getElementById("swipe-wrapper");
const prevBtn = document.getElementById("prev-btn");
const nextBtn = document.getElementById("next-btn");

// 초기 상태
let index = 0;

// swipe prev button logic
prevBtn.addEventListener("click", () => {
    const items = document.querySelectorAll('.item');
    
    if(index > 0) index -= 1;
    let x = 400*index;

    items.forEach((item) => {
        item.style.transform = `translate(-${x}px, 0px)`;
    });

    getMainProjectInfo(index);
    getProgressUI(index); 
});

// swipe next button logic
nextBtn.addEventListener("click", () => {
    const items = document.querySelectorAll('.item');

    if(index < userProjects.length-1) {
        index += 1;
    }
    let x = 400*index;

    items.forEach((item) => {
        item.style.transform = `translate(-${x}px, 0px)`;
    });

    getMainProjectInfo(index); 
    getProgressUI(index);
});

// 결제 모달창
document.getElementById("request-payment").addEventListener('click', () => {
    const modal = document.getElementById("modal");
    console.log(`clicke ${modal.style.display}`);
    if(modal.style.display === 'none') modal.style.display = 'flex';
    else modal.style.display = 'none';
});

document.getElementById("modal-close").addEventListener('click', () => {
    document.getElementById("modal").style.display = 'none';
});

let paytype = 'deposit';
document.querySelectorAll('input[name="paytype"]').forEach((radio) => {
    radio.addEventListener("change", (e) => {
        if(e.target.value === 'deposit') {
            paytype = 'deposit';
            document.getElementById('deposit-box').style.display = 'flex';
            document.getElementById('kakaopay-box').style.display = 'none';
        } else {
            paytype = 'kakaopay';
            document.getElementById('deposit-box').style.display = 'none';
            document.getElementById('kakaopay-box').style.display = 'flex';
        }
    });
});

// 결제하기
async function getPay() {
    if(paytype === 'deposit') {
        // 무통장 입금
        const currentProject = userProjects[index];
        const response = await fetch('/project/getpay-deposit', {
            method: 'POST',
            headers: { "Content-Type" : "application/json" },
            body: JSON.stringify({
                docId: currentProject.docId,
            }),
        });

        const result = await response.json();
        if(!response.ok) {
            console.log(`error: ${result.error}`);
        }
    }
    else if(paytype === 'kakaopay') {
        // 카카오페이 간편 결제
        const currentProject = userProjects[index];
        const response = await fetch('/project/getpay-kakaopay', {
            method: 'POST',
        });        
    }
}

// 무통장입금 결제 요청
document.getElementById('deposit-box').addEventListener('submit', async (e) => {
    await getPay();
    window.location.reload();
});

// 카카오페이 결제 진행
document.getElementById('kakaopay-box').addEventListener('submit', async (e) => {
    e.preventDefault();
});


// 파일 다운로드
async function getFileDownload() {
    const pjt = userProjects[index];
    const response = await fetch('/project/get-download', {
        method: 'POST',
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ docId: pjt.docId }),
    });

    if(!response.ok) {
        const result = await response.text();
        console.log(`error: ${result.error}`);
        return;
    }

    const blob = await response.blob(); // 응답 데이터를 Blob으로 변환
    const fileUrl = URL.createObjectURL(blob); // Blob URL 생성

    const link = document.createElement('a');
    link.href = fileUrl;
    link.download = `draft.jpg`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(fileUrl);
}

document.getElementById('download-file').addEventListener('click', async (e) => {
    e.preventDefault();
    await getFileDownload(); 
});