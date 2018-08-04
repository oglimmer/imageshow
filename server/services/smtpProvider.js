const nodemailer = require('nodemailer');

//const config = {
//    sendmail: true,
//    newline: 'unix',
//    path: '/usr/sbin/sendmail'
//};

const config = {
    host: 'mail.messagingengine.com',
    port: 587,
    secure: false,
    auth: {
        user: 'zimpasser@sent.com',
        pass: 'rdshwt9gutkfcly6'
    }
};

const transporter = nodemailer.createTransport(config);

var smtpProvider = {
	send: async ({ to, subject, body }) => {
		console.log(`sending an email....${to}`);
    const info = await transporter.sendMail({
      from: 'robot@junta-online.net',
      to,
      subject,
      text: body
    });
    // info = { accepted: [ 'mail@olikurt.de' ],
    //   rejected: [],
    //   envelopeTime: 309,
    //   messageTime: 285,
    //   messageSize: 396,
    //   response: '250 2.0.0 Ok: queued as 27AD31026E',
    //   envelope:
    //    { from: 'robot@junta-online.net', to: [ 'mail@olikurt.de' ] },
    //   messageId: '<415fcab8-c8bd-73f9-8908-0a490798a392@junta-online.net>' }
	}  
}

module.exports = smtpProvider;
