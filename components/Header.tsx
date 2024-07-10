import React from "react";
import { View, Text, StyleSheet } from "react-native"; // Import StyleSheet from react-native
import Drake from "./Drake";

const Header = ({ flexValue }: { flexValue: number }) => {
    return (
        <View style={[styles.frame, { flex: flexValue }]}>
            <Text style={styles.header}>thinking about you</Text>
        </View>
    );
  };
  
  const styles = {
    frame: {
      backgroundColor: 'green',
      height: '90%',
      width: '90%',
      justifyContent: 'center',
      alignItems: 'center',
      alignSelf: 'center',
      borderRadius: '100%',
    },
    header: {
      fontSize: 24,
      fontWeight: 'bold',
      textAlign: 'center',
      justifyContent: 'center',
      color: 'white',
    }
  }

export default Header;