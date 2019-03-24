'use strict';
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
var topic = "newCompany";

exports.sendNewCompanyNotification = functions.database.ref('/Companies/{cname}/desc')
.onWrite((change, context) => {
    const name = context.params.cname;
    const payload = {
        notification: {
            title: `New company added - ${name}`,
            body: 'Check your eligibility now!',
        },
	topic: topic
    };
    admin.messaging().send(payload)
	.then((response) => {console.log("Successfully sent message: ", response);})
	.catch((error) => {console.log("ERROR sending messages: ", error);});
    return true;
});
