var subscribeType = '';

async function getUserInitData() {
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        console.log(`subscribe: ${result.subscribe}`);
        subscribeType = result.subscribe;
    } else {
        console.log(`error : ${result.error}`);
    }
}

getUserInitData();