var subscribeType = '';
var docId = '';
var project;
var price = '';

// 로그인 체크
async function checkLogin() {
    const response = await fetch('/login/current-user', {
        method: 'POST',
        credentials: "include",
    });

    if(response.ok) {
        document.getElementById("profile-photo").style.visibility = 'visible';
        document.getElementById("profile-photo").style.display = 'flex';
        document.getElementById("profile-photo").style.flexDirection = 'raw';
        document.getElementById("profile-photo").style.alignItems = 'center';            
        document.getElementById("to-signin").style.display = 'none';

        // 관리자 계정 체크
        const response = await fetch('/login/check-admin', {
            method: 'POST',
            credentials: 'include',
        });

        if(response.ok) {
            document.getElementById('dropdown-management').style.display = 'flex';
        }

    } else {
        document.getElementById("to-signin").style.display = 'block';
    }
}
checkLogin();

// 프로젝트 ID
function getDocId() {
    const queryString = window.location.search;
    const params = new URLSearchParams(queryString);
    docId = params.get('docId');
}


// 프로젝트 가져오기
async function getProject() {
    const response = await fetch('/project/get-project-by-id', {
        method: 'POST',
        headers: {'Content-Type':"application/json"},
        body: JSON.stringify({ docId: docId }),
    });

    if(response.ok) {
        project = await response.json();
    } else {
        console.log(`error: ${response.json().error}`);
    }
}

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

// 프로젝트 가격 가져오기
async function getPrice() {
    const response = await fetch('/project/get-price', {
        method: 'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            docId: docId,
        }),
    });

    const result = await response.json();
    if(response.ok) {
        price = result.price;
    } else {
        price = '---';
    }
}

// 구독 정보 적용
async function getSubscribeInfos() {
    await getUserInitData();

    if(subscribeType === '0') {
        
    } else {
        const response = await fetch('/user/get-subscribe-info', {
            method: 'POST',
        });
    
        const result = await response.json();
        if(response.ok) {
        
        } else {
            console.log(`error: ${result.error}`);
        }
    }
}
getSubscribeInfos();

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
    window.location.href = "/page/login-email.html";
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

        window.location.href="../page/home.html";
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});

// 비밀번호 변경
document.getElementById('update-password').addEventListener('click', async (e) =>  {
    Swal.fire({
        title: '비밀번호 재설정',
        text: '비밀번호를 변경하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소',
    }).then(async (result) => {
        if(result.isConfirmed) {
            try {
                const updateResponse = await fetch('/login/update-password', {
                    method: 'POST',
                    credentials: "include",
                });
                
                if(updateResponse.ok) {
                    Swal.fire('성공', '비밀번호 변경 링크가 전송되었습니다. 이메일을 확인해 주세요.', 'success');
                } else {
                    const errorData = await response.json();
                    console.log(`Error: ${errorData.error}`);
                    Swal.fire('오류', '비밀번호 변경 요청 중 문제가 발생했습니다.', 'error');
                }
            } catch (error) {
                console.error('Request failed:', error);
                Swal.fire('오류', '서버와 통신 중 문제가 발생했습니다.', 'error');
            }
        }
    }); 
});

// main-project-info innerHTML
async function getMainProjectInfo() {
    await getPrice();
    const projectInfo = document.getElementById('main-project-info');
    projectInfo.innerHTML = `
            <div class="description">
                <p class="description-title">기관명</p>
                <p class="description-content" id="organization">${project.organization}</p>
            </div>
            <div class="description">
                <p class="description-title">성함</p>
                <p class="description-content" id="name">${project.name}</p>
            </div>
            <div class="description">
                <p class="description-title">연락처</p>
                <p class="description-content" id="phone">${project.call}</p>
            </div>
            <div class="description">
                <p class="description-title">문의내용</p>
                <p class="description-content" id="details">${project.details}</p>
            </div>
            <div class="description">
                <p class="description-title">요청가격</p>
                <p class="description-content" id="details">${price}</p>
            </div>
        `;

    const projectTitleElement = document.querySelector('.project-name');
    projectTitleElement.innerText = project.title;
}

// progress ui
function getProgressUI() {
    if(project.progress == '0') {
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
    else if(project.progress == '1') {
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
    else if(project.progress == '2') {
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
    else if(project.progress == '3') {
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
    else if(project.progress == '11') {
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
    await getDocId();
    await getProject();
    await getMainProjectInfo();
    await getProgressUI();
}

initProjectInfo();

// 결제 모달창
document.getElementById("request-payment").addEventListener('click', () => {
    const modal = document.getElementById("modal");
    if(modal.style.display === 'none') modal.style.display = 'flex';
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
            document.getElementById('subscribe-box').style.display = 'none';
        } else if(e.target.value === 'kakaopay') {
            paytype = 'kakaopay';
            document.getElementById('deposit-box').style.display = 'none';
            document.getElementById('kakaopay-box').style.display = 'flex';
            document.getElementById('subscribe-box').style.display = 'none';
        } else {
            paytype = 'subscribe';
            document.getElementById('deposit-box').style.display = 'none';
            document.getElementById('kakaopay-box').style.display = 'none';
            document.getElementById('subscribe-box').style.display = 'flex';
        }
    });
});

// 계좌번호 입력 로직
document.getElementById("deposit-num").addEventListener("input", function (e) {
    this.value = this.value.replace(/\D/g, ""); // 숫자가 아닌 문자 제거
});


// 결제하기
async function getPay() {
    if(paytype === 'deposit') {
        // 수동이체
        const responseGetpay = await fetch('/project/getpay-deposit', {
            method: 'POST',
            headers: { "Content-Type" : "application/json" },
            body: JSON.stringify({
                docId: docId,
            }),
        });

        const result = await responseGetpay.json();
        if(!responseGetpay.ok) {
            console.log(`error: ${result.error}`);
        }

        // 예금 정보 등록
        const depositName = document.getElementById('deposit-name');
        const actNum = document.getElementById('deposit-num');
        const responseDepositOwnner = await fetch('/project/upload-deposit-owner', {
            method: 'POST',
            headers: { "Content-Type" : "application/json" },
            body: JSON.stringify({
                owner: depositName.value,
                docId: docId,
                actNum: actNum.value,
            }),
        });       

        const depositResult = await responseDepositOwnner.json();
        if(!responseDepositOwnner.ok) {
            console.log(`error: ${depositResult.error}`);
        }
    }
    else if(paytype === 'kakaopay') {
        // 카카오페이 간편 결제
        const responseGetpay = await fetch('/project/getpay-kakaopay', {
            method: 'POST',
            headers: { "Content-Type" : "application/json" },
            body: JSON.stringify({
                docId: docId,
                userEmail: project.userEmail,
                title: project.title,
                price: price,
            }),
        });

        const result = await responseGetpay.json();
        if(responseGetpay.ok) {
            window.location.href = result.redirectURL;
        } else {
            console.log(`error: ${result.error}`);
        }
    }
    else if(paytype === 'subscribe') {
        if(subscribeType === '0') {
            alert(`구독 중인 구독권이 없습니다.`);
        } else {
            // 구독권 결제
            const title = project.title;
            const response = await fetch('/user/getpay-with-subscribe', {
                method: 'POST',
                headers: { "Content-Type":"application/json" },
                body: JSON.stringify({
                    title: title,
                }),
            });
            
            const result = await response.json();
            if(response.ok) {                
                // 프로젝트 진행현황 업데이트 -> 결제 완료
                const progressResponse = await fetch('/project/check-subscribe-pay', {
                    method: 'POST',
                    headers: { "Content-Type":"application/json" },
                    body: JSON.stringify({
                        docId: docId,
                        price: project.price,
                    }),
                });

                if(progressResponse.ok) {
                    alert('구독권 결제가 완료되었습니다.');
                    window.location.reload();
                } else {
                    console.log(`error: ${progressResponse.json().error}`);
                }
            } else {
                alert(result.error);
            }
        }
    }
}

// 수동이체 결제 요청
document.getElementById('deposit-box').addEventListener('submit', async (e) => {
    e.preventDefault();

    Swal.fire({
        title: '결제',
        text: '수동 이체로 결제하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: "확인",
        cancelButtonText: "취소",
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        }
    }).then( async (result) => {
        if(result.isConfirmed) {
            await getPay();
            window.location.reload();
        }
    });
});

// 카카오페이 결제 진행
document.getElementById('kakaopay-box').addEventListener('submit', async (e) => {
    e.preventDefault();
    await getPay();
});

// 구독권 결제 진행
document.getElementById('subscribe-box').addEventListener('submit', async (e) => {
    e.preventDefault();
    await getPay();
});


// 파일 다운로드
async function getFileDownload() {
    // 로딩화면 띄우기
    const loadingScreen = document.getElementById('loading-screen');
    loadingScreen.style.display = "flex";


    const response = await fetch('/project/get-download', {
        method: 'POST',
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ docId: docId }),
    });

    if(!response.ok) {
        alert('업로드된 파일이 없습니다.');
        return;
    }

    const blob = await response.blob();
    const fileUrl = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = fileUrl;
    link.download = `draft_files.zip`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    URL.revokeObjectURL(fileUrl);

    // 로딩화면 숨기기
    loadingScreen.style.display = 'none';
}

document.getElementById('download-file').addEventListener('click', async (e) => {
    e.preventDefault();
    await getFileDownload(); 
});

// 1200px 이하 유저 메뉴 리스트 열기
document.getElementById('menu-display-btn').addEventListener('click', (e) => {
    const menus = document.getElementById('user-container');
    if(menus.style.left === '0px') {
        console.log('ddd');
        menus.style.left = '-200px';
    } else {
        menus.style.left = '0';
    }
});

// 1200px 이하 유저 메뉴 리스트 닫기
document.addEventListener('click', function (e) {
    const menus = document.getElementById('user-container');
    const btn = document.getElementById('menu-display-btn');
    if (!menus.contains(e.target) && !btn.contains(e.target)) {
        menus.style.left = '-200px';
    }
});