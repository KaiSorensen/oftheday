import React from "react";
import { ScrollView, Button, View } from "react-native";
import Drake from "./Drake";

const Chips = ({ flexValue }: { flexValue: number }) => {
    return (
        <View style={[styles.frame, { flex: flexValue }]}>
            <Button title="fuck me" onPress={() => console.log('Button pressed')} />
        </View>
    );
  };



const styles = {
    frame: {
        backgroundColor: 'white',
        height: '50%',
        borderRadius: '100%',
        marginHorizontal: 3
    }  // Add a background color for visibility
}

export default Chips;