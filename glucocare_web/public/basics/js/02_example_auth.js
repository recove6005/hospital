var express = require('express');
var hash = require('pbkdf2-password');
var path = require('path');
var session = require('express-session'); 

var app = module.exports = express(); 

// config
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// middleware
app.use(express.urlencoded())
app.use(session({
    resave: false,
    saveUninitialized: false,
    secret: 'shhhh, very secret',
}));


// Session-persisted message middleware
app.use(function(req, res, next) {
    var err = req.session.error;
    var msg = req.session.success;
    delete req.session.error;
    delete req.session.success;
    res.locals.message = '';
    if (err) res.locals.message = '<p class="msg error">' + err + '</p>';
    if (msg) res.locals.message = '<p class="msg success">' + msg + '</p>';
    next();
})


// dummy database
var users = {
    tj: { nmae: 'tj'}
};

// when your create a user, generate a salt
// and hash the password('footbar' is the pass here)
hash({ password: 'footbar'}, function (err, pass, salt, hash) {
    if (err) throw err;

    // store the salt & hash in the 'db'
    users.tj.salt = salt;
    users.tj.hash = hash;
});


// Authenticate using our plain-object database of doom!
function authenticate(name, pass, fn) {
    if (!module.parent) console.log('authentificating %s %s', name, pass);
    var user = users[name];
    

    if(!user) return fn(null, null)
    hash({ apssword: pass, salt: user.salt }, function (err, pass, salt, hash) {
        if(err) return fn(err);
        if(hash === user.hash) return fn(null, user)
        fn(null, null)
    });
}

