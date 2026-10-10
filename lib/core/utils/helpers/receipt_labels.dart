import '../../services/business_profile_service.dart';

/// Printed-receipt wording in the language picked under the website's
/// Settings → Receipt. Kept to plain ASCII on purpose: thermal printers'
/// default code page drops or garbles accented characters.
class ReceiptLabels {
  ReceiptLabels._();

  static const _labels = <String, Map<String, String>>{
    'spanish': {
      'Receipt': 'Recibo',
      'Order': 'Pedido',
      'Customer': 'Cliente',
      'Payment': 'Pago',
      'Items': 'Articulos',
      'Subtotal': 'Subtotal',
      'Discount': 'Descuento',
      'Tax': 'Impuesto',
      'Total': 'Total',
      'Paid so far': 'Pagado hasta ahora',
      'Amount due': 'Saldo pendiente',
      'Received': 'Recibido',
      'Change': 'Cambio',
      'PAYMENT RECEIPT': 'RECIBO DE PAGO',
      'Previous due': 'Saldo anterior',
      'Paid now': 'Pagado ahora',
      'Remaining due': 'Saldo restante',
      'PAID IN FULL': 'PAGADO EN SU TOTALIDAD',
      'Estimate': 'Presupuesto',
      'Tel': 'Tel',
    },
    'french': {
      'Receipt': 'Recu',
      'Order': 'Commande',
      'Customer': 'Client',
      'Payment': 'Paiement',
      'Items': 'Articles',
      'Subtotal': 'Sous-total',
      'Discount': 'Remise',
      'Tax': 'Taxe',
      'Total': 'Total',
      'Paid so far': 'Deja paye',
      'Amount due': 'Montant du',
      'Received': 'Recu',
      'Change': 'Monnaie',
      'PAYMENT RECEIPT': 'RECU DE PAIEMENT',
      'Previous due': 'Solde precedent',
      'Paid now': 'Paye maintenant',
      'Remaining due': 'Solde restant',
      'PAID IN FULL': 'ENTIEREMENT PAYE',
      'Estimate': 'Devis',
      'Tel': 'Tel',
    },
    'german': {
      'Receipt': 'Beleg',
      'Order': 'Bestellung',
      'Customer': 'Kunde',
      'Payment': 'Zahlung',
      'Items': 'Artikel',
      'Subtotal': 'Zwischensumme',
      'Discount': 'Rabatt',
      'Tax': 'Steuer',
      'Total': 'Gesamt',
      'Paid so far': 'Bisher bezahlt',
      'Amount due': 'Offener Betrag',
      'Received': 'Erhalten',
      'Change': 'Rueckgeld',
      'PAYMENT RECEIPT': 'ZAHLUNGSBELEG',
      'Previous due': 'Vorheriger Saldo',
      'Paid now': 'Jetzt bezahlt',
      'Remaining due': 'Restbetrag',
      'PAID IN FULL': 'VOLLSTAENDIG BEZAHLT',
      'Estimate': 'Kostenvoranschlag',
      'Tel': 'Tel',
    },
  };

  /// [english] translated into the configured receipt language.
  static String t(String english) => _labels[_language]?[english] ?? english;

  static String get _language =>
      switch (BusinessProfileService.receiptLanguage) {
        'español' || 'espanol' || 'es' => 'spanish',
        'français' || 'francais' || 'fr' => 'french',
        'deutsch' || 'de' => 'german',
        final value => value,
      };
}
