async function getSubscribeType() {
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
    });

    const result = await response.json();
    if(response.ok) {
        return result.subscribe;
    } else {
        console.log(`eroor: ${result.error}`);
        return '';
    }
}

document.getElementById('type1').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();
    if(subscribeType === '0') {
        // 구독권 없음, 초기 결제
        const response = await fetch('/user/subscribe-basic', {
            method: 'POST',
        });
    
        const result = await response.json();
        if(response.ok) {
            const tid = result.tid;
            console.log(`tid: ${tid}`);
            // const urlParams = new URLSearchParams(window.location.search); 
            // const pgToken = urlParams.get('pg_token');

            window.location.href = result.redirectUrl;

            // if(pgToken) {
            //     //sid 발급 요청
            //     const responseSid = await fetch('/user/get-sid', {
            //         method: 'POST',
            //         headers: { "Content-Type" : "application/json" },
            //         body: JSON.stringify({
            //             tid: tid,
            //             pgToken: pgToken,
            //         }),
            //     });

            //     const resultSid = await responseSid.json();
            //     if(responseSid.ok) {
            //         const sid = resultSid.sid;
                    
            //         // 정기 결제 요청
            //         const responsePeriodic = await fetch('/user/subscribe-periodic', {
            //             method: 'POST',
            //             headers: { "Content-Type" : "application/json" },
            //             body: JSON.stringify({
            //                 sid: sid,
            //             }),
            //         });

            //         const resultPeriodic = await response.json();
            //         if(responsePeriodic.ok) {
            //             alert(`구독권(베이직) 정기 결제가 완료 되었습니다. 다음 결제일은 ${result.nextDate} 입니다.`);
            //             window.location.href = "../html/home.html";
            //         } else {
            //             alert(`error: ${resultPeriodic.error}`);
            //         }
            //     } else {
            //         // sid 발급 실패
            //         alert(`error: ${resultSid.error}`);
            //     }
            // } else {
            //     alert(`error: no pg_token found.`);
            // }
        } else {
            console.log(`error: ${result.error}`);
        }
    } else {
        // 이미 구매한 구독권이 있음
        if(subscribeType==='1') alert(`회원님은 현재 [베이직] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
        else if(subscribeType==='2') alert(`회원님은 현재 [스텐다드] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
        else alert(`회원님은 현재 PRIMIUM 구독권 이용 중입니다. [프리미엄] 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
    }
});

document.getElementById('subscribe-type2').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();


});

document.getElementById('subscribe-type3').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();


});
