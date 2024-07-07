import React from "react";
import { View, StyleSheet } from "react-native";
import Drake from "./Drake";

const Content = ({ flexValue }: { flexValue: number }) => {
    return (
    <View style={[styles.frame, { flex: flexValue }]}>
        <View style={styles.content}>
            <Drake />
        </View>
    </View>
    );
};

const styles = StyleSheet.create({
    frame: {
        backgroundColor: 'yellow', // Add a background color for visibility  
        justifyContent: 'center', // Correct string value for justifyContent

    },
    content: {
        width: '90%',
        height: '90%',
        borderRadius: 55, // Numeric value for borderRadius
        overflow: 'hidden', // Correct string value for overflow
        alignSelf: 'center', // Correct string value for alignSelf
        justifyContent: 'center', // Correct string value for justifyContent
        backgroundColor: 'black', // Add a background color for visibility
    },
});

export default Content;
