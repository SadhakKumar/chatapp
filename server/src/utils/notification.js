import { getMessaging } from 'firebase-admin/messaging';

export const sendNotification = async (receiverToken, message) => {
  try {
    const messaging = {
      notification: {
        title: 'New Message',
        body: message
      },
      token: receiverToken,
    };
    const response = await getMessaging().send(messaging);
    console.log('Successfully sent notification:', response);
  } catch (error) {
    console.log('Error sending notification:', error);
    throw error; // Re-throw the error to handle it in the caller function if needed
  }
};