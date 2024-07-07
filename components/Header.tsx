import React from "react";
import { View, Text, StyleSheet } from "react-native"; // Import StyleSheet from react-native
import Drake from "./Drake";

const Header = ({ flexValue }: { flexValue: number }) => {
  return (
    <View style={[styles.content, { flex: flexValue } ]}>
        <Drake/>
    </View>
  );
};

const styles = {
    content: {
        width: '90%',
        height: '90%',
        borderRadius: '55',
        overflow: 'hidden',
        alignSelf: 'center',
        justifyContent: 'center',
        backgroundColor: 'black',
    }
}

// const styles = {

// }

export default Header;