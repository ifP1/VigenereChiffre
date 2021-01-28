import java.util.*;
import java.util.stream.Collectors;

void setup() {
  String toDecrypt = prepareText(appendStrings(loadStrings("gT.txt")));
  //toDecrypt = encode(toDecrypt, "traenen");
  //print(decode(toDecrypt, "Traenen"));
  String Schluessel = quantityAnalyze(toDecrypt, getKeyLength(toDecrypt), 'E');
  System.out.printf("The key to decrypt the given input is the following:%n%s (Length of %d)",Schluessel, Schluessel.length());
  //print(decrypt(toDecrypt));
  exit();
}

String appendStrings(String[] input) {
  String output = "";
  for (int i = 0; i < input.length; i++) {
    output += input[i];
  }
  return output;
}

String prepareText(String text) {
  String output = "";
  text = text.toUpperCase(Locale.ENGLISH);
  for (int i = 0; i < text.length(); i++) {
    if (text.charAt(i) >= 65 && text.charAt(i) <= 90) {
      output += text.charAt(i);
    }
  }
  return output;
}

String encode(String klarText, String Schluessel) {
  return crypt(prepareText(klarText), prepareText(Schluessel), true);
}

String decode(String geheimText, String Schluessel) {
  return crypt(prepareText(geheimText), prepareText(Schluessel), false);
}

String crypt(String text, String Schluessel, boolean ENcrypt) {
  String output = "";
  for (int i = 0; i < text.length(); i++) {
    int currentChar = text.charAt(i);
    currentChar = (((currentChar - 65) + ((Schluessel.charAt(i % Schluessel.length()) - 65)*(ENcrypt ? 1 : -1)) + 26) % 26) + 65;
    output += (char)(currentChar);
  }
  return output;
}

int getKeyLength(String text) {
  //Collect all
  HashMap<String, ArrayList<Integer>> dreierZeichenketten = new HashMap<String, ArrayList<Integer>>();
  int charChainLength = 3;
  for (int i = 0; i <= text.length() - charChainLength; i++) {
    String cur = text.substring(i, i + charChainLength);
    dreierZeichenketten.putIfAbsent(cur, new ArrayList<Integer>());
    dreierZeichenketten.get(cur).add(i);
  }
  
  //Collect all distances
  ArrayList<Integer> allDistances = new ArrayList<Integer>();
  Object[] allKeys = dreierZeichenketten.keySet().toArray();
  for (int i = 0; i < allKeys.length; i++) {
    ArrayList<Integer> tempSpacings = dreierZeichenketten.get(allKeys[i]);
    if (tempSpacings.size() <= 1) {
      continue;
    }
    for (int j = 0; j < tempSpacings.size() - 1; j++) {
      allDistances.add(tempSpacings.get(j + 1) - tempSpacings.get(j));
    }
  }

  //Collect all factors
  ArrayList<Integer> allFactors = new ArrayList<Integer>();
  for (int i = 0; i < allDistances.size(); i++) {
    int temp = allDistances.get(i);
    for (int j = 3; j < temp; j++) {
      if (temp % j == 0) {
        allFactors.add(j);
      }
    }
  }

  //Select most common factor
  HashMap<Integer, Integer> factorQuantity = new HashMap<Integer, Integer>();
  for (int i = 0; i < allFactors.size(); i++) {
    int tempFactor = allFactors.get(i);
    if (factorQuantity.containsKey(tempFactor)) {
      int tempCount = factorQuantity.get(tempFactor);
      tempCount++;
      factorQuantity.put(tempFactor, tempCount);
    } else {
      factorQuantity.put(tempFactor, 1);
    }
  }
  int mostCommonFactor = 0;
  int quantityOfMostCommonFactor = 0;
  for (int i = text.length() - 1; i >= 0; i--) {
    if (factorQuantity.containsKey(i)) {
      if (factorQuantity.get(i) > quantityOfMostCommonFactor) {
        mostCommonFactor = i;
        quantityOfMostCommonFactor = factorQuantity.get(i);
      }
    }
  }

  return mostCommonFactor;
}

String quantityAnalyze(String text, int keyLength, char mostCommonChar) {
  String Schluessel = "";
  for (int i = 0; i < keyLength; i++) {
    int[] charQuantity = new int[26];
    for (int j = i; j < text.length(); j += keyLength) {
      charQuantity[text.charAt(j) - 65]++;
    }
    int highestQuantity = 0;
    int highestQuantityIndex = 0;
    for (int j = 0; j < charQuantity.length; j++) {
      if (charQuantity[j] > highestQuantity) {
        highestQuantity = charQuantity[j];
        highestQuantityIndex = j;
      }
    }
    char keyPart = (char)(((highestQuantityIndex - (mostCommonChar - 65) + 26) % 26) + 65);
    Schluessel += keyPart;
  }
  return Schluessel;
}

String decrypt(String geheimText) {
  int keyLength = getKeyLength(geheimText);
  String Schluessel = quantityAnalyze(geheimText, keyLength, 'E');
  return decode(geheimText, Schluessel);
}
