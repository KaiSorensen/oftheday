import React from "react";
import { View, Text, StyleSheet } from "react-native"; // Import StyleSheet from react-native
import Drake from "./Drake";

const Header = ({ flexValue }: { flexValue: number }) => {
  return (
    <View style={{ flex: flexValue }}>
        <Drake/>
    </View>
  );
};

// const styles = {

// }

export default Header;