import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { google } from 'googleapis';

admin.initializeApp();
const db = admin.firestore();

export const verifyPlaySubscription = functions.https.onCall(async (data, context) => {
  const purchaseToken: string = data.purchaseToken;
  const productId: string = data.productId;
  const packageName: string = data.packageName;
  const uid: string = data.uid;

  if (!purchaseToken || !productId || !packageName || !uid) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing parameters');
  }

  try {
    const auth = new google.auth.GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const androidpublisher = google.androidpublisher({ version: 'v3', auth });

    const resp = await androidpublisher.purchases.subscriptions.get({
      packageName,
      subscriptionId: productId,
      token: purchaseToken,
    });

    const body: any = resp.data;
    const valid = body && body.paymentState === 1 || body.cancelReason === 0;

    if (valid) {
      const expiryMs = parseInt(body.expiryTimeMillis, 10);
      const expiryDate = new Date(expiryMs);
      await db.collection('users').doc(uid).set({
        isSubscribed: true,
        subscriptionExpiry: expiryDate,
      }, { merge: true });
    }

    return { valid };
  } catch (e: any) {
    console.error('Verification error', e);
    throw new functions.https.HttpsError('internal', e.message ?? 'verify error');
  }
});