// 로그인 체크
async function checkLogin() {
    const response = await fetch('/login/current-user', {
        method: 'POST',
        credentials: "include",
    });

    if(!response.ok) {
        document.getElementById("to-signin").style.display = 'block';
    }
}
checkLogin();

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
            document.getElementById("to-signin").style.display = 'block';
        } 
        else {
            document.getElementById("profile-photo").style.visibility = 'visible';
            document.getElementById("profile-photo").style.display = 'flex';
            document.getElementById("profile-photo").style.flexDirection = 'raw';
            document.getElementById("profile-photo").style.alignItems = 'center';            
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
        console.log(result.msg);
    } catch(e) {
    console.error("Unexpected error during logout:", error);
    alert("An unexpected error occurred. Please try again.");
    }
});


// 프로젝트 id 가져오기
function getDocId() {
    const url = new URL(window.location.href);
    const params = new URLSearchParams(url.search);
    const docId = params.get('projectid');
    return docId;
}

// 프로젝트 정보 가져오기
let title = '';
let organization = '';

async function getProjectInfo() {
    const docId = getDocId();
    const response = await fetch('/project/get-project-by-id', {
        method: 'POST',
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ docId: docId }),
    });

    const result = await response.json();

    if(response.ok) {
        title = result.title;
        document.getElementById('project-title').innerText = title;

        const date = new Date(result.date);
        const year = date.getFullYear();
        const month = String(date.getMonth()+1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const formattedDate = `${year}-${month}-${day}`;

        document.getElementById('date').innerText = formattedDate;
        organization = result.organization;
        document.getElementById('organization').innerText = organization;
        document.getElementById('name').innerText = result.name;
        document.getElementById('call').innerText = result.call;
        document.getElementById('email').innerText = result.email;
        document.getElementById('details').innerText = result.details;
    } else {
        console.log(`error: ${result.error}`);
    }
}

// 프로젝트 progress 가져오기
async function getProgress() {
    const docId = getDocId();
    const response = await fetch('/project/get-project-by-id', {
        method: 'POST',
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ docId: docId }),
    });

    const result = await response.json();

    if(response.ok) {
        return result.progress;
    } else {
        console.log(`error: ${result.error}`);
        return '';
    }
}

// 예금주 정보 가져오기
async function getDepositInfo() {
    const docId = getDocId();

    const response = await fetch('/project/download-deposit-owner', {
        method: 'POST',
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({
            docId: docId,
        }),
    });

    const result = await response.json();
    let owner = '';
    if(response.ok) {
        owner = result.owner;
        document.getElementById('deposit').innerText = owner;
    } else {
        console.log(`error: ${result.error}`);
    }
}

// 프로젝트 progress에 따른 버튼 display
async function buttonDisplay() {
    // 버튼 엘리먼트
    const acceptBtn = document.getElementById('accept-btn');
    const rejectBtn = document.getElementById('reject-btn');
    const payRequestForm = document.getElementById('pay-request-form');
    const payCheckBtn = document.getElementById('pay-check-btn');
    const progressTitle = document.getElementById('progress');

    const progress = await getProgress();
    console.log(progress);

    if(progress === '0') {
        progressTitle.innerText = '문의 접수';
        acceptBtn.style.display = 'flex';
        rejectBtn.style.display = 'flex';
        payRequestForm.style.display = 'none';
        payCheckBtn.style.display = 'none';
    }
    else if(progress === '1') {
        progressTitle.innerText = '작업 중';
        acceptBtn.style.display = 'none';
        rejectBtn.style.display = 'none';
        payRequestForm.style.display = 'flex';
        payCheckBtn.style.display = 'none';
    }
    else if(progress === '2') {
        progressTitle.innerText = '결제 중';
        acceptBtn.style.display = 'none';
        rejectBtn.style.display = 'none';
        payRequestForm.style.display = 'none';
        payCheckBtn.style.display = 'none';
    }
    else if(progress === '11') {
        progressTitle.innerText = '결제 중';
        const deposit = getDepositInfo();
        acceptBtn.style.display = 'none';
        rejectBtn.style.display = 'none';
        payRequestForm.style.display = 'none';
        payCheckBtn.style.display = 'flex';
    }
    else if(progress === '3') {
        progressTitle.innerText = '결제 완료';
        acceptBtn.style.display = 'none';
        rejectBtn.style.display = 'none';
        payRequestForm.style.display = 'none';
        payCheckBtn.style.display = 'none';
    }    
}

// 디스플레이 함수 실행
getProjectInfo();
buttonDisplay();

// project-accept
document.getElementById('accept-btn').addEventListener('click', async (e) => {
    e.preventDefault();
    const docId = getDocId();
    Swal.fire({
        title: '수락',
        text: `문의를 수락하시겠습니까?`,
        showCancelButton: true,
        confirmButtonText: "확인",
        cancelButtonText: "취소",
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        }
    }).then(async (result) => {
        const response = await fetch('/project/accept-project', {
            method: 'POST',
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ docId: docId }),
        });
        const acceptResult = await response.json();
        if(response.ok) {
            window.location.reload();
        } else {
            console.log(`error: ${acceptResult.error}`);
        }
    });
});

// project-reject
document.getElementById('reject-btn').addEventListener('click', async (e) => {
    e.preventDefault();
    const docId = getDocId();

    Swal.fire({
        title: '거부',
        text: `문의를 삭제 하시겠습니까?`,
        showCancelButton: true,
        confirmButtonText: "확인",
        cancelButtonText: "취소",
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        }
    }).then(async (result) => {
        const response = await fetch('/project/dismiss-project', {
            method: 'POST',
            headers: {"Content-Type":"application/json"},
            body: JSON.stringify({docId: docId}),
        });
    
        const rejectResult = await response.json();
        if(response.ok) {
            window.location.reload();
        } else {
            console.log(`error: ${rejectResult.error}`);
        }
    });
});


// pay-request
const priceInput = document.getElementById('price');
let rawPrice = 0;
const filesInput = document.getElementById('files');

priceInput.addEventListener("input", (e) => {
    // 결제input 문자열 제한 - 숫자만 입력
    const rawValue = e.target.value.replace(/[^\d]/g, "");
    rawPrice = rawValue;

    const formattedValue = new Intl.NumberFormat("ko-KR").format(rawValue);
    e.target.value = formattedValue ? `${formattedValue}` : "";
});


document.getElementById('pay-request-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const price = rawPrice;
    const files = filesInput.files;
    const docId = getDocId();

    const formData = new FormData();
    formData.append("docId", docId);
    formData.append("price", price);

    for(let index = 0; index < files.length; index++) {
        formData.append(`files`, files[index]);
    }

    Swal.fire({
        title: '결제 요청',
        text: `${price}원으로 결제 요청 하시겠습니까?`,
        showCancelButton: true,
        confirmButtonText: "확인",
        cancelButtonText: "취소",
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        }
    }).then(async (result) => {
        if(result.isConfirmed) {
            // progress 1 -> 2
            // 파일 업로드 및 결제 요청 처리
            const response = await fetch('/project/request-payment', {
                method: 'POST',
                body: formData,
            });

            const result = await response.json();
            if(response.ok) {
                Swal.fire({
                    icon: 'success',
                    title: '',
                    text: `${organization}에서 문의한 ${title} 프로젝트의 ${price}원 결제 요청이 완료되었습니다.`,
                    confirmButtonText: '확인',
                    customClass: {
                        confirmButton: 'swal-confirm-btn',
                    }
                }).then(() => {
                    window.location.reload();                             
                });
            } else {
                console.log(`payment error: ${result.error}`);
            }
        }
    });
});

// 결과확인 버튼 이벤트
document.getElementById('pay-check-btn').addEventListener('click', async (e) => {
    const docId = getDocId();

    Swal.fire({
        title: '무통장입금 결제확인',
        text: '무통장 입금 결제를 확정하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소',
        customClass: {
            confirmButton: 'swal-confirm-btn',
            cancelButton: 'swal-cancel-btn',
        },
    }).then( async (result) => {
        if(result.isConfirmed) {
            const response = await fetch('/project/check-deposit', {
                method: 'POST',
                headers: { "Content-Type": "application/json"},
                body: JSON.stringify({ docId: docId }),
            });

            const result = await response.json();
            if(response.ok) {
                window.location.reload();
            } else {
                console.log(`error: ${result.error}`);
            }

            Swal.fire('', '무통장 입금이 확인되었습니다.', 'success');
        }
    });
});
